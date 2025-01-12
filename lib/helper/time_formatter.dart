import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


String formatTimeStamp(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  return DateFormat('HH:mm • dd MMM yy').format(dateTime);
}