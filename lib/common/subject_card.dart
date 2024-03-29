import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ml_project/constants/constants.dart';

import 'package:ml_project/models/subject_model.dart';

class SubjectCard extends ConsumerWidget {
  final Subject subject;
  final Color color;
  const SubjectCard({
    super.key,
    required this.subject,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
            image: DecorationImage(
              image: subject.backGroundImageUrl.isNotEmpty
                  ? ExactAssetImage(
                      subject.backGroundImageUrl,
                    )
                  : ExactAssetImage(Constants.subjectBackground[0]),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.3),
                BlendMode.dstATop,
              ),
            ),
            color: color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 1,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ]),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subject.createdBy,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Subject Type: ${subject.subjectType}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            overflow: TextOverflow.ellipsis),
                      ),
                      (subject.subjectJoiningCode.isNotEmpty)
                          ? Text(
                              "Subject Joining code: ${subject.subjectJoiningCode}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  overflow: TextOverflow.ellipsis),
                            )
                          : const SizedBox(),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
