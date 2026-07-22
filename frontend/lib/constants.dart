import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// --- Sizes & Spacing ---
const double kPaddingXS = 4.0;
const double kPaddingS = 8.0;
const double kPaddingM = 16.0;
const double kPaddingL = 24.0;
const double kPaddingXL = 32.0;

const double kRadiusS = 8.0;
const double kRadiusM = 12.0;
const double kRadiusL = 20.0;
const double kRadiusXL = 30.0;

const double kIconSmall = 18.0;
const double kIconMedium = 24.0;
const double kIconLarge = 32.0;

// --- Strings ---
const String kAppName = 'Thiru Annamalaiyar Snacks';
const String kCurrency = '₹';
const String kDeliveryCharge = 'Delivery Charge';
const String kTotalAmount = 'Total Amount';
const String kPlaceOrder = 'Place Order via WhatsApp';
const String kViewCart = 'View Cart';
const String kExtraChargesNote = 'Extra charges may apply';
const String kItems = 'Items';
const String kItem = 'Item';
const String kFulfillmentMethod = 'Fulfillment Method';
const String kChooseFulfillment = 'Choose how you get your order';
const String kDelivery = 'Delivery';
const String kStorePickup = 'Store Pickup';

// --- Settings ---
const String kSettings = 'Settings';
const String kAccount = 'ACCOUNT';
const String kMyOrders = 'My Orders';
const String kActiveOrders = 'Active Orders';
const String kSavedAddresses = 'Saved Addresses';
const String kSupportLegal = 'SUPPORT & LEGAL';
const String kContactUs = 'Contact Us';
const String kHelpFaq = 'Help & FAQ';
const String kRateReview = 'Rate & Review';
const String kPrivacyPolicy = 'Privacy Policy';
const String kTermsConditions = 'Terms & Conditions';
const String kSession = 'SESSION';
const String kLogOut = 'Log Out';
const String kDeleteAccount = 'Delete Account';
const String kEdit = 'Edit';
const String kDescription = 'Description';
const String kHighlights = 'Highlights';
const String kAuthentic = 'Authentic';
const String kHomemade = 'Homemade';
const String kFreshlyMade = 'Freshly Made';
const String kNoPreservatives = 'No Preservatives';
const String kInCartContinue = 'In Cart • Continue';
const String kAddToCart = 'Add to Cart';
const String kAdd = 'ADD';

// --- Cart & Checkout ---
const String kMyCart = 'My Cart';
const String kEmptyCartTitle = 'Your cart is empty';
const String kEmptyCartSubtitle =
    "Looks like you haven't added any snacks yet. Explore our menu and find something delicious!";
const String kStartShopping = 'Start Shopping';
const String kOrderItems = 'Order Items';
const String kDeliveryAddress = 'Delivery Address';
const String kPickupFrom = 'Pickup From';
const String kSelectCity = 'Select Delivery City';
const String kSelectBranch = 'Select Store Branch';
const String kYouMayLike = 'You may also like!';
const String kAddNote = 'Add a note for Annamalaiyar';
const String kOrderSuccess = 'Order Placed Successfully!';
const String kOrderIdPrefix = 'Order ID: #';
const String kWhatsAppConfirm = 'Click OK to confirm your order on WhatsApp.';
const String kOk = 'OK';
const String kPlaceOrderTitle = 'Place Order';

// --- Home & Misc ---
const String kWhatsOnMind = "WHAT'S ON YOUR MIND ?";
const String kRecommendedItems = 'RECOMMENDED ITEMS';
const String kViewAllSnacks = 'View All Snacks';
const String kRetry = 'Retry';
const String kShopNow = 'SHOP NOW';
const String kFooterDesc =
    'Preserving the rich culinary heritage of Chettinad through authentic flavours and traditional recipes.';
const String kContact = 'CONTACT';
const String kCopyright = '© 2025 Annamalaiyar Chettinadu Snacks. Karaikudi';
const String kWhatsAppUs = 'WhatsApp Us';
const String kEmailUs = 'Email Us';
const String kNoSnacksFound = 'No snacks found here';
const String kNoSnacksSubtitle = 'Check back later for more deliciousness!';
const String kSearchSnacksHint = 'Search snacks, sweets...';
const String kSearchSnacksAction = 'Search for your favorite snacks';
const String kNoResultsFor = 'No results found for';
const String kTrySearchingElse = 'Try searching for something else';

// --- API ---
final String kBaseUrl = dotenv.get('API_BASE_URL', fallback: 'https://thiru-annamalaiyar-snacks.up.railway.app');
const int kMaxRetries = 3;
const Duration kNetworkTimeout = Duration(seconds: 10);

// --- Colors ---
const Color kGold = Color(0xFFC8882A);
const Color kGoldLight = Color(0xFFF5C97A);
const Color kGoldPale = Color(0xFFFFF8EC);
const Color kRed = Color(0xFFB03A2A);
const Color kCream = Color(0xFFFAF5EC);
const Color kDark = Color(0xFF1A1009);
const Color kDark2 = Color(0xFF2C1A08);
const Color kText = Color(0xFF3D2208);
const Color kTextMuted = Color(0xFF7A5C3A);
const Color kWhite = Colors.white;
const Color kBlack = Colors.black;
const Color kVegColor = Color(0xFF008000);
const Color kNonVegColor = Color(0xFF8B0000);
