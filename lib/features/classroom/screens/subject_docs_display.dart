import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ml_project/common/document_card.dart';
import 'package:ml_project/features/auth/controller/auth_controller.dart';
import 'package:ml_project/features/classroom/screens/detailed_file_upload_screen.dart';
import 'package:ml_project/features/my_classroom/controller/my_classroom_controller.dart';
import 'package:ml_project/models/subject_model.dart';

class SubjectDocsDisplyScreen extends ConsumerStatefulWidget {
  final Subject subject;
  final bool isPermission;
  const SubjectDocsDisplyScreen({
    super.key,
    required this.subject,
    required this.isPermission,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SubjectDocsDisplyScreenState();
}

class _SubjectDocsDisplyScreenState
    extends ConsumerState<SubjectDocsDisplyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.subject.name),
        ),
        body: widget.isPermission
            ? ref
                .watch(getClassroomDocumentsProvider(
                    widget.subject.subjectJoiningCode))
                .when(
                  data: (data) {
                    setState(() {});
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            Container(
                              decoration:
                                  const BoxDecoration(color: Colors.grey),
                              height: 1,
                            ),
                            const SizedBox(height: 20),
                            (data.isEmpty)
                              ? Center(
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 210),
                                      Image.asset("assets/nothingToSeeHere.png",
                                          height: 200),
                                      const Text("Nothing to see here!",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                print("From ui part ${data[index].fileName}");
                                // return ListTile(
                                //   title: Container(
                                //     height: 50,
                                //     padding: const EdgeInsets.all(10),
                                //     decoration: BoxDecoration(
                                //         border:
                                //             Border.all(color: Colors.black, width: 0.5),
                                //         borderRadius: BorderRadius.circular(10)),
                                //     child: Text(
                                //       data[index].fileName,
                                //     ),
                                //   ),
                                // );
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20.0),
                                  child: DocumentCard(
                                    document: data[index],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  error: (error, stackTrace) =>
                      Text("Error ${error.toString()}"),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                )
            : const Text("Permission Denied"),
        floatingActionButton: (ref.read(userProvider)!.uid != widget.subject.creatorId) ? const SizedBox() : Container(
          padding: const EdgeInsets.all(5.0),
          height: 70,
          width: 70,
          child: FloatingActionButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            backgroundColor: Colors.white,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DetailedFileUploadScreen(subjectJoiningCode: widget.subject.subjectJoiningCode,)));
            },
            child: const Icon(
              Icons.add,
              size: 32,
            ),
          ),
        ));
  }
}
