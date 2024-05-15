import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:pettag/chat/widgets/route_generator.dart';
import 'screens/editOwnerInfo.dart';
import 'screens/screens.dart';
import 'package:pettag/utilities/appData.dart';
import 'package:pettag/widgets/mySearchDialog.dart';
import 'package:pettag/widgets/subscriptionDealCard.dart';
import 'addmophelper.dart';
import 'firebase_options.dart';
import 'services/sharedPref.dart';

final appData = AppData();

final sharedPrefs = SharedPrefs();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AdMobHelper.initialization();
  await sharedPrefs.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Locales.init(['en', 'es', 'hi', 'pt', 'zh']);
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LocaleBuilder(
      builder: (locale) => MaterialApp(
        localizationsDelegates: Locales.delegates,
        supportedLocales: Locales.supportedLocales,
        locale: locale,
        useInheritedMediaQuery: true,

        title: 'PetTag',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          unselectedWidgetColor: Colors.black.withOpacity(0.4),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.pink)
              .copyWith(secondary: Colors.white),
        ),
        //home: PetDetailedScreen(),
        home: const SplashScreen(),
        onGenerateRoute: RouteGenerator.generateRoute,
        routes: {
          HomeScreen.homeScreenRoute: (BuildContext ctx) =>  const HomeScreen(),
          OwnerProfile.ownerProfileScreenRoute: (BuildContext ctx) =>
              const OwnerProfile(),
          AllProfiles.allProfilesScreenRoute: (BuildContext ctx) =>
              const AllProfiles(),
          SplashScreen.splashScreenRoute: (BuildContext ctx) =>
               const SplashScreen(),
          SignInScreen.secondScreenRoute: (BuildContext ctx) =>
               const SignInScreen(),
          TreatScreen.treatScreenRoute: (BuildContext ctx) => const TreatScreen(),
          SignUpPlan.singUpPlanRoute: (BuildContext ctx) => const SignUpPlan(),
          EditOwnerInfoScreen.editOwnerInfoScreenRoute: (BuildContext ctx) =>
               const EditOwnerInfoScreen(),
          EditInfoScreen.editInfoScreenRoute: (BuildContext ctx) =>
              EditInfoScreen(),
          EditProfileScreen.editProfileScreenRoute: (BuildContext ctx) =>
               EditProfileScreen(),
          AddNewProfileScreen.addNewProfileScreenRoute: (BuildContext ctx) =>
               const AddNewProfileScreen(),
          RegisterScreen.registerScreenRoute: (BuildContext context) =>
              const RegisterScreen(),
          SecondRegisterScreen.secondRegisterScreenRoute:
              (BuildContext context) => const SecondRegisterScreen(),
          AgreeScreen.agreeScreenRoute: (BuildContext context) => const AgreeScreen(),
          AboutScreen.aboutScreenRoute: (BuildContext context) => const AboutScreen(),
          PetMatch.petMatchScreenRoute: (BuildContext context) => const PetMatch(),
          PetLiked.petLikedScreenRoute: (BuildContext context) => const PetLiked(),
          TopPickedPet.TopPickedPetScreenRoute: (BuildContext context) =>
              const TopPickedPet(),
          PetDetailedScreen.petDetailedScreenRoute: (BuildContext context) =>
              const PetDetailedScreen(),
          AppointmentScreen.appointmentScreenRoute: (BuildContext context) =>
              const AppointmentScreen(),
          PetChatScreen.petChatScreenRoute: (BuildContext context) =>
              const PetChatScreen(),
          PetSlideScreen.petSlideScreenRouteName: (BuildContext context) =>
              PetSlideScreen(),
          PetProfileScreen.petProfileScreenRouteName: (BuildContext context) =>
              const PetProfileScreen(isJustPreview: false,),
          SettingsScreen.settingsScreenRoute: (BuildContext context) =>
               const SettingsScreen(),
          UserDetails.userDetailsRoute: (BuildContext ctx) => const UserDetails(petId: '', ownerId: '', isMyProfile: false,),
          AddNewFeed.addNewFeedScreenRoute: (BuildContext ctx) => const AddNewFeed(),
          SubscriptionDealCard.subscriptionDealCardScreenRoute:
              (BuildContext ctx) => SubscriptionDealCard(),
          MySearchDialog.mySearchDialogScreenDialog: (BuildContext ctx) =>
              MySearchDialog(),
          PushNotification.pushNotificationScreenRoute: (BuildContext ctx) =>
              const PushNotification(),
          EmailNotification.emailNotificationScreenRoute: (BuildContext ctx) =>
              const EmailNotification(),
          ImageZoomScreen.imageZoomScreenRoute: (BuildContext ctx) =>
               const ImageZoomScreen(),
          PTPlus.ptPlusScreenRoute: (BuildContext ctx) => const PTPlus(ownerId: '', petId: '',),
          MultiplePetDetailedScreen.petDetailedScreenRoute:
              (BuildContext ctx) => const MultiplePetDetailedScreen(),
          PermissionDisclosureScreen.permissionDisclosureRoute:
              (BuildContext ctx) => const PermissionDisclosureScreen(),
        },
      ),
    );
  }
}
