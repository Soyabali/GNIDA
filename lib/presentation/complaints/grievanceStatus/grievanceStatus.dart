import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import '../../../app/generalFunction.dart';
import '../../../services/UpdateRatingOnComplaintRepo.dart';
import '../../../services/citizenMyPostedComplaint.dart';
import '../../circle/circle.dart';
import '../../fullscreen/imageDisplay.dart';
import '../../nodatavalue/NoDataValue.dart';
import '../../resources/app_text_style.dart';

class GrievanceStatus extends StatefulWidget {

  final name;

  GrievanceStatus({super.key, this.name});

  @override
  State<GrievanceStatus> createState() => _TemplesHomeState();
}

class _TemplesHomeState extends State<GrievanceStatus> {

  GeneralFunction generalFunction = GeneralFunction();

  var variableName;
  var variableName2;
  List<Map<String, dynamic>>? pendingInternalComplaintList;
  List<Map<String, dynamic>> _filteredData = [];
  List bindAjencyList = [];
  List userAjencyList = [];
  var iAgencyCode;
  var agencyUserId;
  TextEditingController _searchController = TextEditingController();
  double? lat;
  double? long;
  final distDropdownFocus = GlobalKey();
  var result, msg;
  var userAjencyData;
  var result1;
  var msg1;
  GeneralFunction generalfunction = GeneralFunction();
  bool isLoading = true;
  var isFeedback;
  var fRating;
  late final List<String> items;
  var ratingItem;
  double _currentRating = 0.0;
  Map<String, double> ratings = {};

  // Api response

  // pendingInternalComplaintResponse() async {
  //   pendingInternalComplaintList = await CitizenMyPostComplaintRepo().cityzenpostcomplaint(context);
  //   print('-----53----$pendingInternalComplaintList');
  //   _filteredData = List<Map<String, dynamic>>.from(pendingInternalComplaintList ?? []);
  //   print("----58---$_filteredData");
  //
  //   setState(() {
  //     // parkList=[];
  //     isLoading = false;
  //   });
  // }
  Future<void> pendingInternalComplaintResponse() async {
    pendingInternalComplaintList = await CitizenMyPostComplaintRepo().cityzenpostcomplaint(context);

    setState(() {
      _filteredData = List<Map<String, dynamic>>.from(pendingInternalComplaintList as Iterable);
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    pendingInternalComplaintResponse();
    _searchController.addListener(_search);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _searchController.dispose();
    super.dispose();
  }

  // void _search() {
  //   String query = _searchController.text.toLowerCase();
  //   setState(() {
  //     _filteredData = pendingInternalComplaintList?.where((item) {
  //           String location = item['sPointTypeName'].toLowerCase();
  //           String pointType = item['iCompCode'].toLowerCase();
  //           String sector = item['sSectorName'].toLowerCase();
  //           return location.contains(query) ||
  //               pointType.contains(query) ||
  //               sector.contains(query);
  //         }).toList() ??
  //         [];
  //   });
  // }
  void _search() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      _filteredData = pendingInternalComplaintList!.where((item) {
        String location = (item['sPointTypeName'] ?? '').toString().toLowerCase();
        String pointType = (item['iCompCode'] ?? '').toString().toLowerCase(); // 👈 convert int to string
        String sector = (item['sSectorName'] ?? '').toString().toLowerCase();

        return location.contains(query) ||
            pointType.contains(query) ||
            sector.contains(query);
      }).toList();
    });
  }

  // location
  void getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    lat = position.latitude;
    long = position.longitude;
    setState(() {});
  }

  void displayToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Unfocus any focused widget
        },
        child: WillPopScope(
          onWillPop: () async => false,
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              backgroundColor: Colors.white,
             appBar: getAppBarBack(context, '${widget.name}'),
              // appBar: getAppBarBack(context,'jjsjsjsj'),
              //  drawer: generalFunction.drawerFunction(context, 'Suaib Ali', '9871950881'),
              body: isLoading
                  ? Center(child: Container())
                  : (pendingInternalComplaintList == null ||
                     pendingInternalComplaintList!.isEmpty)
                      ? NoDataScreenPage()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Center(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 15, right: 15, top: 10),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    border: Border.all(
                                      color: Colors.grey, // Outline border color
                                      width: 0.2, // Outline border width
                                    ),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _searchController,
                                          autofocus: true,
                                          // onChanged: (value) {
                                          //   _search(); // 👈 call your custom search function
                                          // },
                                          decoration: const InputDecoration(
                                            prefixIcon: Icon(Icons.search),
                                            hintText: 'Enter Keywords',
                                            hintStyle: TextStyle(
                                                fontFamily: 'Montserrat',
                                                color: Color(0xFF707d83),
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // scroll item after search bar
                            Expanded(
                              child: ListView.builder(
                                itemCount: _filteredData.length ?? 0,
                                itemBuilder: (context, index) {
                                  Map<String, dynamic> item = _filteredData[index];

                                  fRating = "${item['fRating']}";
                                  double? ratingValue = double.tryParse(fRating);

                                  return Padding(
                                    padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
                                    child: Container(
                                      child: Column(
                                        children: [
                                          Card(
                                            elevation: 4,
                                            shadowColor: Colors.white,
                                            child: Container(
                                              color: Colors.white,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 5),
                                                  Container(
                                                    padding: EdgeInsets.all(1.0), // Padding of 5.0
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.black26, // Border color
                                                        width: 1.0, // Border width (optional, default is 1.0)
                                                      ),
                                                    ),
                                                    child: ListTile(
                                                      leading: Image.asset(
                                                        'assets/images/home12.jpeg',
                                                        height: 25,
                                                        width: 25,
                                                        fit: BoxFit.cover, // Ensures the image fits well
                                                      ),
                                                      title: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              item['sPointTypeName'].toString() ?? '',
                                                              style: AppTextStyle.font14penSansExtraboldBlack45TextStyle,
                                                              maxLines: 2,
                                                              // Ensure the title doesn't exceed two lines
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                          SizedBox(width: 4),
                                                          GestureDetector(
                                                            onTap: () {
                                                              var image =
                                                                  "${item['sBeforePhoto']}";
                                                              print(
                                                                  '------260----$image');
                                                              // FullScreenImages
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        FullScreenImages(
                                                                            image:
                                                                                image)),
                                                              );
                                                            },
                                                            child: Image.asset(
                                                              'assets/images/picture.png',
                                                              height: 25,
                                                              width: 25,
                                                              fit: BoxFit.fill,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),

                                                  SizedBox(height: 5),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      SizedBox(width: 5),
                                                      CircleWithSpacing(),
                                                      Text('Complaint No',
                                                          style: AppTextStyle
                                                              .font14OpenSansRegularBlack45TextStyle),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 24),
                                                    child: Text(item['iCompCode'].toString() ??
                                                            '',
                                                        style: AppTextStyle
                                                            .font14OpenSansRegularRedTextStyle),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      SizedBox(width: 5),
                                                      CircleWithSpacing(),
                                                      Text('Sector', style: AppTextStyle.font14OpenSansRegularBlack45TextStyle),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 24),
                                                    child: Text(
                                                        item['sSectorName'] ??
                                                            '',
                                                        style: AppTextStyle
                                                            .font14penSansExtraboldBlack26TextStyle),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      SizedBox(width: 5),
                                                      CircleWithSpacing(),
                                                      Text('Agency Name',
                                                          style: AppTextStyle
                                                              .font14OpenSansRegularBlack45TextStyle),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(left: 24),
                                                    child: Text(
                                                        item['sAgencyName'] ?? '',
                                                        style: AppTextStyle.font14penSansExtraboldBlack26TextStyle),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      SizedBox(width: 5),
                                                      CircleWithSpacing(),
                                                      Text('Posted At',
                                                          style: AppTextStyle
                                                              .font14OpenSansRegularBlack45TextStyle),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 24),
                                                    child: Text(
                                                        item['dPostedOn'] ?? '',
                                                        style: AppTextStyle
                                                            .font14penSansExtraboldBlack26TextStyle),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      SizedBox(width: 5),
                                                      CircleWithSpacing(),
                                                      Text("Location",
                                                          style: AppTextStyle
                                                              .font14OpenSansRegularBlack45TextStyle),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 24),
                                                    child: Text(
                                                        item['sLocation'] ?? '',
                                                        style: AppTextStyle
                                                            .font14penSansExtraboldBlack26TextStyle),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      SizedBox(width: 5),
                                                      CircleWithSpacing(),
                                                      Text('Description',
                                                          style: AppTextStyle
                                                              .font14OpenSansRegularBlack45TextStyle),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 24),
                                                    child: Text(
                                                        item['sDescription'] ??
                                                            '',
                                                        style: AppTextStyle
                                                            .font14penSansExtraboldBlack26TextStyle),
                                                  ),
                                                  // status
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      SizedBox(width: 5),
                                                      CircleWithSpacing(),
                                                      Text('Status',
                                                          style: AppTextStyle
                                                              .font14OpenSansRegularBlack45TextStyle),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 24),
                                                    child: Text(
                                                        item['sStatusName'] ??
                                                            '',
                                                        style: AppTextStyle
                                                            .font14OpenSansRegularRedTextStyle),
                                                  ),

                                                  SizedBox(height: 5),

                                                  if (ratingValue != null &&
                                                      ratingValue == 0.0)
                                                    Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          // RatingBar
                                                          RatingBar.builder(
                                                            initialRating: 0.0,
                                                            // Initial rating value
                                                            minRating: 1,
                                                            // Minimum rating allowed
                                                            direction:
                                                                Axis.horizontal,
                                                            allowHalfRating:
                                                                true,
                                                            itemCount: 5,
                                                            // Number of stars
                                                            itemSize: 40.0,
                                                            // Size of each star
                                                            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                                            itemBuilder:
                                                                (context, _) =>
                                                                    const Icon(
                                                              Icons.star,
                                                              color: Colors.amber,
                                                            ),
                                                            onRatingUpdate:
                                                                (rating) {
                                                              setState(() {
                                                                _currentRating =
                                                                    rating; // Update the current rating value
                                                              });
                                                            },
                                                          ),

                                                          ElevatedButton(
                                                            onPressed:
                                                                () async {
                                                              print(
                                                                  "-----434-----");
                                                              // var rating = "${items[index]}";
                                                              // var rating="2";
                                                              var iCompCode =
                                                                  "${item['iCompCode']}";
                                                              //  ratingItem

                                                              print(
                                                                  "-----460--IcompCode--$iCompCode");
                                                              print(
                                                                  "-----460--ratingItem--$_currentRating");

                                                              var updateRating =
                                                                  await UpdateRatingonComplaintRepo().updateRatingOnComplaint(
                                                                      context,
                                                                      iCompCode,
                                                                      _currentRating);

                                                              result =
                                                                  "${updateRating['Result']}";
                                                              msg =
                                                                  "${updateRating['Msg']}";
                                                              displayToast(msg);
                                                              if (result ==
                                                                  "1") {
                                                                /// call a first api again
                                                                pendingInternalComplaintResponse();
                                                                _searchController
                                                                    .addListener(
                                                                        _search);
                                                                displayToast(
                                                                    msg);
                                                              } else {
                                                                displayToast(
                                                                    msg);
                                                              }
                                                            },
                                                            child: Text(
                                                                "Rating",
                                                                style: AppTextStyle
                                                                    .font14OpenSansRegularBlack45TextStyle),
                                                          ),
                                                        ])
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
            ),
          ),
        ));
  }
}

class NoDataScreen extends StatelessWidget {
  const NoDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No Record Found',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
