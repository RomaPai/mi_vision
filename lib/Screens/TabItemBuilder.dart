import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mi_vision/Utils/db%20utils.dart';

class TabItemCardBuilder extends StatefulWidget {
  final String userId;

  const TabItemCardBuilder({Key? key, required this.userId}) : super(key: key);
  @override
  _TabItemCardBuilderState createState() => _TabItemCardBuilderState();
}

class _TabItemCardBuilderState extends State<TabItemCardBuilder> {
  FirebaseFirestore ffInstance = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: ffInstance.collection(widget.userId).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final int itemsCount = snapshot.data!.docs.length;

        return Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 4),
          child: StaggeredGridView.countBuilder(
              physics: BouncingScrollPhysics(),
              itemCount: itemsCount,
              crossAxisCount: 8,
              mainAxisSpacing: 24,
              crossAxisSpacing: 28,
              staggeredTileBuilder: (int index) => new StaggeredTile.fit(4),
              itemBuilder: (context, index) {
                final DocumentSnapshot document = snapshot.data!.docs[index];

                return Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Container(
                    color: Colors.white,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: AspectRatio(
                                      aspectRatio: index.isOdd ? 0.9 : 0.6,
                                      child: FancyShimmerImage(
                                        imageUrl: document['downloadURL'],
                                      ))),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(left: 20, right: 20, top: 8),
                              child: Wrap(
                                children: [
                                  Text(
                                    document['labels'].join(', '),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.nunitoSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xff231942)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          child: Icon(
                            Icons.delete,
                            size: 18,
                            color: Colors.black45,
                          ),
                          onTap: () {
                            deleteItem(document.id, widget.userId);
                            showSnackBar('Item is deleted!', context);
                          },
                        )
                      ],
                    ),
                  ),
                );
              }),
        );
      },
    );
  }
}
