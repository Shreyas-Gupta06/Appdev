// import 'package:flutter/material.dart';
// import '../services/auth_service.dart';

// class TestPage extends StatefulWidget {
//   @override
//   _TestPageState createState() => _TestPageState();
// }

// class _TestPageState extends State<TestPage> {
//   final AuthService _authService = AuthService();
//   String responseText = "Click a button to test API";

//   void testSendEmailOTP() async {
//     var response = await _authService.sendEmailOTP("test@example.com");
//     setState(() {
//       responseText = response.toString();
//     });
//   }

//   void testVerifyEmailOTP() async {
//     var response = await _authService.verifyEmailOTP(
//       "test@example.com",
//       "123456",
//     );
//     setState(() {
//       responseText = response.toString();
//     });
//   }

//   void testSendPhoneOTP() async {
//     var response = await _authService.sendPhoneOTP("9999999999");
//     setState(() {
//       responseText = response.toString();
//     });
//   }

//   void testVerifyPhoneOTP() async {
//     var response = await _authService.verifyPhoneOTP("9999999999", "123456");
//     setState(() {
//       responseText = response.toString();
//     });
//   }

//   void testRequestPasswordReset() async {
//     var response = await _authService.requestPasswordReset("test@example.com");
//     setState(() {
//       responseText = response.toString();
//     });
//   }

//   void testResetPassword() async {
//     var response = await _authService.resetPassword(
//       "test@example.com",
//       "123456",
//       "newpassword123",
//     );
//     setState(() {
//       responseText = response.toString();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Test API Calls")),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text(responseText, textAlign: TextAlign.center),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: testSendEmailOTP,
//               child: Text("Send Email OTP"),
//             ),
//             ElevatedButton(
//               onPressed: testVerifyEmailOTP,
//               child: Text("Verify Email OTP"),
//             ),
//             ElevatedButton(
//               onPressed: testSendPhoneOTP,
//               child: Text("Send Phone OTP"),
//             ),
//             ElevatedButton(
//               onPressed: testVerifyPhoneOTP,
//               child: Text("Verify Phone OTP"),
//             ),
//             ElevatedButton(
//               onPressed: testRequestPasswordReset,
//               child: Text("Request Password Reset"),
//             ),
//             ElevatedButton(
//               onPressed: testResetPassword,
//               child: Text("Reset Password"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
