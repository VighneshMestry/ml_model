import 'dart:convert';
import 'dart:io';

import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ml_project/check_permissions.dart';
import 'package:ml_project/common/subject_card.dart';
import 'package:ml_project/constants/constants.dart';
import 'package:ml_project/features/auth/controller/auth_controller.dart';
import 'package:ml_project/features/auth/repository/services.dart';
import 'package:ml_project/features/home/drawers/profile_drawer.dart';
import 'package:ml_project/features/home/screens/file_upload_screen.dart';
import 'package:ml_project/features/home/screens/my_subject_docs_display.dart';
import 'package:ml_project/models/document_model.dart';
import 'package:ml_project/features/home/screens/search_sreen.dart';
import 'package:uuid/uuid.dart';

class FetchScreen extends ConsumerStatefulWidget {
  const FetchScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FetchScreenState();
}

// AIDS - 0, DMBI - 1, EHF - 2, WT - 3, WEBX - 4
class _FetchScreenState extends ConsumerState<FetchScreen> {
  bool isPermission = false;
  CheckPermission checkAllPermissions = CheckPermission();

  checkPermission() async {
    var permission = await checkAllPermissions.isStoragePermission();
    if (permission) {
      setState(() {
        isPermission = true;
      });
    }
  }

  void hanlingScannedImages(File file) async {
    final scannedDocId = const Uuid().v1();
    await ref
        .read(servicesProvider.notifier)
        .uploadPDF(context, file, scannedDocId);
    String singleFilePath = await ref
        .read(servicesProvider.notifier)
        .getPdfDownloadUrl(scannedDocId);
    // ignore: use_build_context_synchronously
    await ref
        .read(servicesProvider.notifier)
        .contactServer(context, singleFilePath)
        .then((content) async {
      final predictions = predict(content);
      final docId = const Uuid().v1();
      Doc document = Doc(
                fileName: scannedDocId,
                assignmentTitle: "New Assignment",
                assigmentDescription: "Assignment Description",
                userId: ref.read(userProvider)!.uid,
                docId: docId,
                subjectJoiningCode: "",
                type: "img",
                fileUrl: singleFilePath,
                prediction: Constants.subjectTypes[predictions],
                aiFileExists: false,
                createdAt:
                    "${DateFormat("dd-MM-yyyy").format(DateTime.now())} ${TimeOfDay.now()}",
                tags: []);
      await ref.read(servicesProvider.notifier).uploadToFirebase(document);
      setState(() {});
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Image uploaded to ${document.prediction}")));
    }).catchError((error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    });
  }

  dynamic _model;

  int predict(String inputText) {
    if (_model == null ||
        !_model.containsKey('vocabulary') ||
        !_model.containsKey('class_prior') ||
        !_model.containsKey('feature_count')) {
      return -1; // Return an error code or handle the error appropriately
    }

    final vocabulary = _model['vocabulary'];
    final classPrior = _model['class_prior'];
    // final featureCount = _model['feature_count'];
    // final classCount = _model['class_count'];

    // Tokenize the input text using the same CountVectorizer vocabulary
    final List<String> tokens = inputText.toLowerCase().split(RegExp(r'\W+'));

    // Initialize variables to store probabilities for each class
    final List<double> classProbabilities = List.filled(classPrior.length, 0.0);

    // Calculate log probabilities for each class
    for (int i = 0; i < classPrior.length; i++) {
      double logProbability = _model['class_prior'][i];

      for (String token in tokens) {
        if (vocabulary.containsKey(token)) {
          final tokenIndex = _model['vocabulary'][token];
          logProbability += _model['feature_count'][i][tokenIndex];
        }
      }

      classProbabilities[i] = logProbability;
    }

    // Select the class with the highest probability
    int predictedClass = 0;
    double maxProbability = classProbabilities[0];

    for (int i = 1; i < classProbabilities.length; i++) {
      if (classProbabilities[i] > maxProbability) {
        maxProbability = classProbabilities[i];
        predictedClass = i;
      }
    }
    return predictedClass;
  }

  @override
  void initState() {
    super.initState();

    checkPermission();
    loadModel();
  }

  Future<void> loadModel() async {
    // Load the serialized model from assets
    final String modelData = await rootBundle
        .loadString('assets/multinomial_naive_bayes_model.json');

    // Parse the JSON data
    final Map<String, dynamic> modelMap = json.decode(modelData);
    _model = modelMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        }),
        title: const Text("My Space"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 0, top: 14),
            child: IconButton(
                onPressed: () async {
                  // NotificationServices n = NotificationServices();
                  // RemoteMessage message = RemoteMessage(
                  //     notification: RemoteNotification(
                  //         title: "Hello",
                  //         body: "This is notificaiton",
                  //         android: AndroidNotification(channelId: "0")));
                  // await n.showNotification(message);
                  // setState(() {});

                  // ref.read(authControllerProvider.notifier).logOut();
                  // Navigator.of(context).push(MaterialPageRoute(
                  //     builder: (context) => const LoginScreen()));

                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SearchScreen()));
                },
                icon: const Icon(
                  Icons.search,
                  size: 28,
                )),
          ),
          Padding(
              padding: const EdgeInsets.only(
                  left: 12, top: 12, bottom: 12, right: 15),
              child: IconButton(
                  onPressed: () async {
                    // await LaunchApp.openApp(
                    //   androidPackageName: 'com. whatsapp',
                    //   // iosUrlScheme: 'pulsesecure://',
                    //   // appStoreLink: 'itms-apps://itunes.apple.com/us/app/pulse-secure/id945832041',
                    //   // openStore: false
                    // );
                    await DeviceApps.openApp('com.whatsapp');

                    // Enter the package name of the App you want to open and for iOS add the URLscheme to the Info.plist file.
                    // The `openStore` argument decides whether the app redirects to PlayStore or AppStore.
                    // For testing purpose you can enter com.instagram.android
                  },
                  icon: const Icon(Icons.published_with_changes_outlined,
                      size: 28)))
        ],
      ),
      drawer: const ProfileDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(color: Colors.grey),
                height: 1,
              ),
              const SizedBox(height: 20),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: Constants.defaultSubjects.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {});
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MySubjectDocsDisplayScreen(
                            isPermission: isPermission,
                            subject: Constants.defaultSubjects[index],
                          ),
                        ),
                      );
                    },
                    child: SubjectCard(
                      subject: Constants.defaultSubjects[index],
                      color: Constants.subjectColors[index],
                    ),
                  );
                },
              ),
              //   ref.watch(fetchDocsProvider).when(
              //       data: (data) {
              //         return ListView.builder(
              //           itemCount: data.length,
              //           itemBuilder: (context, index) {
              //             return Text(data[index].fileName);
              //           },
              //         );
              //       },
              //       error: (error, stackTrace) => Text(error.toString()),
              //       loading: () => const CircularProgressIndicator()),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        padding: const EdgeInsets.all(5.0),
        height: 70,
        width: 70,
        child: FloatingActionButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          backgroundColor: Colors.white,
          onPressed: () {
            showDialog(
              barrierDismissible: true,
              context: context,
              builder: (context) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      height: 200,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const FileUploadScreen()));
                              },
                              style: TextButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 30)),
                              child: const Text("Files Upload",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal)),
                            ),
                            Container(
                              height: 1,
                              color: Colors.grey.shade300,
                            ),
                            TextButton(
                              onPressed: () async {
                                XFile file = await ref
                                    .watch(servicesProvider.notifier)
                                    .scanImages(ImageSource.camera);
                                setState(() {});
                                File scannedFile = File(file.path);
                                hanlingScannedImages(scannedFile);
                              },
                              style: TextButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 30)),
                              child: const Text(
                                "Scan",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ],
                        ),
                      )),
                );
              },
            );
          },
          child: const Icon(
            Icons.add,
            size: 32,
          ),
        ),
      ),
    );
  }
}
