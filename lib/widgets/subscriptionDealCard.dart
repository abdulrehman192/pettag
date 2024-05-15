import 'package:flutter/material.dart';
import 'package:pettag/models/packageData.dart';

class SubscriptionDealCard extends StatefulWidget {
  static const String subscriptionDealCardScreenRoute = "SubscriptionDealCard";

  SubscriptionDealCard({ this.pkgData,  this.indexExt});

  PackageData? pkgData;
  int? indexExt;

  @override
  _SubscriptionDealCardState createState() => _SubscriptionDealCardState();
}

class _SubscriptionDealCardState extends State<SubscriptionDealCard> {

  int indexExtra = 0;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Visibility(
            visible: indexExtra==widget.indexExt,
            child: Container(
              height: 130,
              width: MediaQuery.of(context).size.width / 3.1,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: Colors.redAccent,
                  width: 2,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 70,
            width: 130,
            child: ListTile(
              onTap: () {
                setState(() {
                  indexExtra = widget.pkgData!.index!;
                  print("Index Extra : $indexExtra");
                });
              },
              contentPadding: const EdgeInsets.all(0),
              subtitle: Container(
                child: Column(
                  children: [
                    Text(
                      widget.pkgData!.duration!,
                      style: const TextStyle(
                        color: Color(0xFF854D5E),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "months",
                      style: TextStyle(
                        color: Color(0xFF854D5E),
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      "\$${widget.pkgData!.price}/month",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: indexExtra==widget.indexExt,
            child: Positioned(
              top: 8,
              left: 10,
              right: 10,
              child: Container(
                height: 35,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    widget.pkgData!.plan!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*SizedBox(
            height: 130,
            width: MediaQuery.of(context).size.width/3.1,
            child: Card(
              elevation: 6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    duration,
                    style: TextStyle(
                      color: Color(0xFF854D5E),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "months",
                    style: TextStyle(
                      color: Color(0xFF854D5E),
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    "\$$price/month",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),*/
