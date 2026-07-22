import twilio from 'twilio';

// =============================================================================
// OTP Service
// =============================================================================
// Handles OTP generation, storage, and verification
// Uses Redis in production for distributed storage, falls back to in-memory Map for development

const OTP_EXPIRY_SECONDS = 5 * 60; // 5 minutes

// Generate a random OTP code
const makeCode = () => Math.floor(100000 + Math.random() * 900000).toString();

// -----------------------------------------------------------------------------
// Storage Backend
// -----------------------------------------------------------------------------

interface OtpStorage {
  set: (phoneNumber: string, code: string, expiresAt: number) => Promise<void>;
  get: (phoneNumber: string) => Promise<{ code: string; expiresAt: number } | null>;
  delete: (phoneNumber: string) => Promise<void>;
}

// In-memory storage (for development)
class InMemoryStorage implements OtpStorage {
  private store = new Map<string, { code: string; expiresAt: number }>();

  async set(phoneNumber: string, code: string, expiresAt: number): Promise<void> {
    this.store.set(phoneNumber, { code, expiresAt });
    // Clean up expired entries
    const now = Date.now();
    for (const [key, entry] of this.store.entries()) {
      if (now >= entry.expiresAt) {
        this.store.delete(key);
      }
    }
  }

  async get(phoneNumber: string): Promise<{ code: string; expiresAt: number } | null> {
    const entry = this.store.get(phoneNumber);
    if (!entry) return null;
    if (Date.now() >= entry.expiresAt) {
      this.store.delete(phoneNumber);
      return null;
    }
    return entry;
  }

  async delete(phoneNumber: string): Promise<void> {
    this.store.delete(phoneNumber);
  }
}

// -----------------------------------------------------------------------------
// Storage Factory
// -----------------------------------------------------------------------------

// Use in-memory storage by default
// To enable Redis storage in production:
// 1. Install redis package: npm install redis
// 2. Uncomment the RedisStorage class below
// 3. Update getStorage() to use RedisStorage when REDIS_URL is set

let storage: OtpStorage = new InMemoryStorage();

// Note: For production, consider implementing RedisStorage
// export class RedisStorage implements OtpStorage { ... }

// For now, always use in-memory storage
export function getStorage(): OtpStorage {
  return storage;
}

// -----------------------------------------------------------------------------
// Twilio Configuration
// -----------------------------------------------------------------------------

const accountSid = process.env.TWILIO_ACCOUNT_SID;
const authToken = process.env.TWILIO_AUTH_TOKEN;
const twilioPhoneNumber = process.env.TWILIO_PHONE_NUMBER;

// Make Twilio optional - OTP can still work in development without it
let twilioClient: any = null;

if (accountSid && authToken && twilioPhoneNumber) {
  twilioClient = twilio(accountSid, authToken);
} else if (process.env.NODE_ENV === 'production') {
  console.warn('⚠️ Twilio credentials not configured. OTP cannot be sent via SMS in production.');
}

// -----------------------------------------------------------------------------
// OTP Service Functions
// -----------------------------------------------------------------------------

export const generateAndSendOtp = async (phoneNumber: string): Promise<{ code: string; expiresAt: number }> => {
  const code = makeCode();
  const expiresAt = Date.now() + OTP_EXPIRY_SECONDS * 1000;

  // Store OTP
  await getStorage().set(phoneNumber, code, expiresAt);

  // Send OTP via SMS using Twilio (if configured)
  if (twilioClient && twilioPhoneNumber) {
    try {
      await twilioClient.messages.create({
        body: `Your E-Shop OTP is: ${code}\n\nValid for 5 minutes.\n\n- E-Shop Team`,
        from: twilioPhoneNumber,
        to: phoneNumber,
      });
      console.log(`📱 OTP sent to ${phoneNumber} via SMS`);
    } catch (error: any) {
      console.error('⚠️ SMS error:', error.message);
      console.log(`🔑 OTP for ${phoneNumber}: ${code} (SMS failed - check Twilio config)`);
    }
  } else {
    if (process.env.NODE_ENV !== 'production') {
      console.log(`🔑 OTP for ${phoneNumber}: ${code} (development mode - no SMS)`);
    }
  }

  return { code, expiresAt };
};

export const verifyOtp = async (phoneNumber: string, code: string): Promise<boolean> => {
  const entry = await getStorage().get(phoneNumber);
  
  if (!entry) {
    return false;
  }

  if (entry.code !== code) {
    return false;
  }

  await getStorage().delete(phoneNumber);
  
  return true;
};

// For testing purposes - allows verification without actual OTP
export const getStoredOtp = async (phoneNumber: string): Promise<string | null> => {
  const entry = await getStorage().get(phoneNumber);
  return entry?.code || null;
};
