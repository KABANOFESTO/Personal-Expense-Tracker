import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static Future<void> sendResetPasswordEmail(
      String recipientEmail, String resetLink) async {
    final smtpServer = gmail('kabanofesto1.com', 'KSMKEPIM1');

    final message = Message()
      ..from = Address('kabanofesto1@gmail.com', 'relax-pay')
      ..recipients.add(recipientEmail)
      ..subject = 'Password Reset Request'
      ..text = 'Click on this link to reset your password: $resetLink';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent. Error: $e');
      throw e;
    }
  }
}
