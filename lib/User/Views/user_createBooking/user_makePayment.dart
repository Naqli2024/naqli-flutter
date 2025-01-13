import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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




class PaymentSuccessScreen extends StatefulWidget {
  final VoidCallback onContinuePressed;

  const PaymentSuccessScreen({Key? key, required this.onContinuePressed})
      : super(key: key);

  @override
  _PaymentSuccessScreenState createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.bounceOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 150,
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Thank you for your payment.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 15),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.057,
                width: MediaQuery.of(context).size.width * 0.4,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    widget.onContinuePressed();
                  },
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class PaymentFailureScreen extends StatefulWidget {
  final VoidCallback onRetryPressed;
  final String paymentStatus;

  const PaymentFailureScreen({Key? key, required this.onRetryPressed, required this.paymentStatus})
      : super(key: key);

  @override
  _PaymentFailureScreenState createState() => _PaymentFailureScreenState();
}

class _PaymentFailureScreenState extends State<PaymentFailureScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.bounceOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Icon(
                    FontAwesomeIcons.exclamationTriangle,
                    color: Colors.red,
                    size: 150,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Payment Failed!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.paymentStatus.isNotEmpty
                  ? widget.paymentStatus[0].toUpperCase() + widget.paymentStatus.substring(1).toLowerCase()
                  : '',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            Container(
              margin: const EdgeInsets.only(top: 15),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.057,
                width: MediaQuery.of(context).size.width * 0.4,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    widget.onRetryPressed();
                  },
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
