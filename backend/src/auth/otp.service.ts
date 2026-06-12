import twilio from 'twilio';

type OtpEntry = {
    code: string;
    expiresAt: number;
};

const store = new Map<string, OtpEntry>();
const makeCode = () => Math.floor(100000 + Math.random() * 900000).toString();

// Configure Twilio client
const accountSid = process.env.TWILIO_ACCOUNT_SID;
const authToken = process.env.TWILIO_AUTH_TOKEN;
const twilioPhoneNumber = process.env.TWILIO_PHONE_NUMBER;

if (!accountSid || !authToken || !twilioPhoneNumber) {
    throw new Error('Twilio credentials are not configured in .env file');
}

const client = twilio(accountSid, authToken);

export const generateAndSendOtp = async (phoneNumber: string) => {
    const code = makeCode();
    const expiresAt = Date.now() + 1000 * 60 * 5; // 5 minutes

    store.set(phoneNumber, { code, expiresAt });

    // Send OTP via SMS using Twilio
    try {
        await client.messages.create({
            body: `Your E-Shop OTP is: ${code}\n\nValid for 5 minutes.\n\n- E-Shop Team`,
            from: twilioPhoneNumber,
            to: phoneNumber,
        });
        console.log(`📱 OTP sent to ${phoneNumber}`);
    } catch (error: any) {
        console.error('⚠️ SMS error:', error.message);
        // Fallback: Log OTP to console for development
        console.log(`🔑 OTP for ${phoneNumber}: ${code} (SMS failed - check Twilio config)`);
    }

    return { code, expiresAt };
};

export const verifyOtp = (phoneNumber: string, code: string) => {
    const entry = store.get(phoneNumber);
    if (!entry) return false;
    if (Date.now() > entry.expiresAt) {
        store.delete(phoneNumber);
        return false;
    }
    if (entry.code !== code) return false;

    store.delete(phoneNumber);
    return true;
};
