import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentPage extends StatefulWidget {
  final String checkoutId;
  final String integrity;

  PaymentPage({required this.checkoutId, required this.integrity});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView(); // Enable hybrid composition
    }
  }

  @override
  Widget build(BuildContext context) {
    // HTML structure for payment widget
    final String html = '''
      <!DOCTYPE html>
      <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"> <!-- Viewport settings -->
        <style>
          body {
            margin: 0;
            padding: 15px 15px;
            overflow: hidden; 
            display: flex;
            justify-content: center;
            align-items: center;
          }
          .paymentWidgets {
            width: 30%; /* Width to make it responsive */
            max-width: 100px; /* Prevent excessive width on larger screens */
            box-sizing: border-box; /* Include padding in width */
          }
        </style>
          <script>
              function loadPaymentScript(checkoutId, integrity) {
                        const script = document.createElement('script');
                        script.src = "https://eu-test.oppwa.com/v1/paymentWidgets.js?checkoutId=" + checkoutId;
                        script.crossOrigin = 'anonymous';
                        script.integrity = integrity;
              
                        script.onload = () => {
                console.log('Payment widget script loaded');
                // Additional functionality can be placed here
                const paymentForm = document.querySelector('.paymentWidgets'); // Adjust selector if necessary
                if (paymentForm) {
                          paymentForm.addEventListener('submit', (event) => {
                            event.preventDefault(); // Prevent default form submission
                            // Custom logic to handle the form submission or payment process
                            console.log('Payment form submitted');
                            // You could add AJAX call here to handle payment server-side if needed
                          });
                        }
                      };
              
                        // Append script to body or a specific element where the form will be displayed
                        document.body.appendChild(script);
                      }
              
                      // Call the loadPaymentScript function with parameters
                      document.addEventListener("DOMContentLoaded", function() {
                        loadPaymentScript("${widget.checkoutId}", "${widget.integrity}");
                      });
          </script>
        </head>
        <body>
          <form action="https://example.com/payment-result" class="paymentWidgets" data-brands="VISA MASTER AMEX"></form>
        </body>
      </html>
    ''';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: Text('Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: WebView(
          initialUrl: Uri.dataFromString(html,
              mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
              .toString(),
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            // Optional: Enable debugging
            webViewController.clearCache(); // Optional: Clear cache
          },
        ),
      ),
    );
  }
}


class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Payment',
      initialRoute: '/',
      routes: {
        '/': (context) => PaymentSuccess(),
        '/payment-success': (context) => PaymentSuccess(),
      },
    );
  }
}

class PaymentSuccess extends StatelessWidget {
  const PaymentSuccess({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment Success')),
      body: Center(child: Text('Success')),
    );
  }
}