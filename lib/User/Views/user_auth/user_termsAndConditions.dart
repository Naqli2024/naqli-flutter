import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;

class UserTermsAndConditions extends StatefulWidget {
  const UserTermsAndConditions({super.key});

  @override
  State<UserTermsAndConditions> createState() => _UserTermsAndConditionsState();
}

class _UserTermsAndConditionsState extends State<UserTermsAndConditions> {
  final ScrollController _scrollController = ScrollController();
  Locale currentLocale = Locale('en', 'US');
  void _scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          centerTitle: false,
          automaticallyImplyLeading: false,
          title: SvgPicture.asset(
            'assets/naqlee-logo.svg',
            fit: BoxFit.fitWidth,
            height: 40,
          ),
          actions: [
            Stack(
              children: [
                Directionality(
                  textDirection: ui.TextDirection.ltr,
                  child: PopupMenuButton<Locale>(
                    color: Colors.white,
                    offset: const Offset(0, 55),
                    icon: Icon(Icons.language, color: Colors.blue),
                    onSelected: (Locale locale) {
                      setState(() {
                        currentLocale = locale;
                        context.setLocale(locale);
                      });
                    },
                    itemBuilder: (BuildContext context) {
                      Locale currentLocale = context.locale;
                      return <PopupMenuEntry<Locale>>[
                        PopupMenuItem(
                          value: Locale('en', 'US'),
                          child: Directionality(
                            textDirection: ui.TextDirection.ltr,
                            child: Row(
                              children: [
                                Text(
                                  'English'.tr(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: Locale('ar', 'SA'),
                          child: Directionality(
                            textDirection: ui.TextDirection.ltr,
                            child: Row(
                              children: [
                                Text(
                                  'Arabic'.tr(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: Locale('hi', 'IN'),
                          child: Directionality(
                            textDirection: ui.TextDirection.ltr,
                            child: Row(
                              children: [
                                Text(
                                  'Hindi'.tr(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ];
                    },
                  ),
                ),
              ],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(90.0),
            child: AppBar(
              scrolledUnderElevation: 0,
              centerTitle: false,
              toolbarHeight: 80,
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xff6A66D1),
              title: Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 40),
                  child: Text('Terms and Conditions'.tr(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_sharp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: currentLocale == Locale('ar', 'SA')
              ? Padding(
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "سياسة الخصوصية لتطبيق نقلي",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "1. المقدّمة",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Text(
                    '1.1.تشكل سياسة الخصوصية هذه ("السياسة") عقدًا قانونيًا ملزمًا وقابل للتنفيذ بينك ("المستخدم") وبين مؤسسة بيانات الحاسب (المالك والمشغل والمتحكِم والمسؤول عن سياسة الخصوصية في تطبيق "نقلي")، لذا يرجى قراءتها بعناية تامة قبل استخدام التطبيق.',
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Text(
                    '1.2.نحترم خصوصية جميع المستخدمين، ونلتزم بحماية بياناتهم الشخصيّة، لذلك أعددنا هذه السياسة لتساعدك على فهم الإجراءات والممارسات التي تتبعها مؤسسة بيانات الحاسب عند جمع واستخدام ومشاركة البيانات الشخصيّة، وكيفية تأمين هذه البيانات، والتعامل معها عند زيارة واستخدام تطبيق "نقلي".',
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "2. الموافقة على السياسة",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Text(
                    '2.1.بوصولك أو استخدامك لتطبيق "نقلي"، فأنت تقر بأنك قرأت هذه السياسة وشروط الاستخدام ("الشروط والأحكام") وتوافق صراحة على الالتزام بجميع البنود الواردة فيها. ',
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Text(
                    '2.2.باستخدامك لتطبيق "نقلي" أو إجراء طلبات من خلاله، فأنت توافق صراحةً على طريقة جمع واستخدام ومعالجة وتخزين بياناتك الشخصيّة بموجب هذه السياسة، والسماح لنا بالتواصل معك لإبلاغك بمعلومات حول الخدمات والمنتجات التي قد تهمك، والموافقة على أيّ تغييرات نجريها مستقبلاً في سياسة الخصوصية. إذا كنت توافق على الممارسات الموضحة في هذه السياسة، فلا يجوز لك استخدام هذا التطبيق.',
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "3. نطاق السياسة",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 0),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            '3.1.تنطبق هذه السياسة على كل من يزور أو يتصفح أو يستخدم تطبيق "نقلي" بما في ذلك المعلومات والبيانات والخدمات والأدوات وجميع الصفحات والأنشطة الأخرى التي نقدمها على التطبيق أو من خلاله.',
                            textAlign: TextAlign.left,
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '3.2.لا تنطبق هذه السياسة على أيّ مواقع أو تطبيقات أو خدمات أخرى تابعة لجهات خارجية ترتبط بتطبيق "نقلي"، ولا تنطبق على المعلومات المقدّمة أو المجمعة من خلال المواقع التي تحتفظ بها شركات أو مؤسسات أخرى.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "4. المبادئ العامة للخصوصية",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "وضعت مؤسسة بيانات الحاسب مبادئ مهمة تتعلق بالبيانات الشخصيّة للمستخدمين، وهي:",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                      child: Text(
                        '4.1.نشر وتحديث هذه السياسة -كلما كان لازماً- لتوضيح الممارسات المتّبعة عند استخدام تطبيق "نقلي".',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        "4.2.جمع واستخدام البيانات الشخصيّة وفقاً للأغراض المحددة في هذه السياسة.",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        "4.3.معالجة البيانات الشخصيّة بما يتوافق مع أغراض الجمع والاستخدام والمشاركة.",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        "4.4.اتخاذ خطوات معقولة للتأكد وضمان أن المعلومات الشخصيّة موثوقة، ودقيقة، وكاملة، ومحدّثة.",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        "4.5.اتخاذ إجراءات مناسبة لتوفير حماية كافية للبيانات التي يتم الإفصاح عنها لأطراف أخرى.",
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "5. طرق جمع البيانات",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'يجمع تطبيق "نقلي" البيانات الشخصيّة من المستخدمين بطرق مختلفة على النحو التالي:',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '5.1.التفاعلات المباشرة',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Text(
                    '5.1.1.بيانات الحساب: عند تسجيل حساب في تطبيق "نقلي"، يقدم لنا المستخدم بيانات محددة، تشمل: الاسم، والبريد الالكتروني، ورقم الجوال، وأي بيانات إضافية تطلبها إدارة التطبيق.',
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Text(
                    '5.1.2.بيانات التواصل: عند التواصل معنا من خلال الوسائل المتاحة في التطبيق، أو الرد على الرسائل التي تصلك على البريد الإلكتروني، مثل اسم المستخدم، والبريد الإلكتروني، وعنوان الرسالة، والموضوع.',
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Text(
                    '5.1.3.بيانات الطلب: عند تقديم طلب شراء لأحد المنتجات من خلال تطبيق "نقلي"، فإننا نجمع بيانات الطلب مثل اسم المستلم، والنوع، والكمية، والمبلغ الإجمالي للطلب، ورقم الهاتف، وعنوان الشحن والفواتير، وأي بيانات أخرى نراها ضرورية أو مطلوبة بموجب الأنظمة واللوائح المعمول بها.',
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Text(
                    '5.1.4.بيانات الدفع: عند دفع مقابل الطلبات، فإنه يجب على العميل دفع مقابلها من خلال أحد الوسائل المتاحة بالتطبيق، ويتم تقديم بيانات الدفع إلى مزودي خدمات الدفع المتعاقد معها لمعالجة عملية الدفع.',
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Text(
                    '5.1.5.بيانات الاشتراك: عند الاشتراك في النشرات البريدية، أو إكمال أي نماذج أخرى يوفرها التطبيق.',
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Text(
                    '5.1.6.بيانات المشاركات: عند إضافة الملاحظات، أو الآراء، أو التعليقات.',
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "5.2.التفاعلات الآلية",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "5.2.1.البيانات التقنية: وتشمل عنوان بروتوكول (IP) لربط جهازك بشبكة الانترنت، ونوع المتصفح، وصفحات الإحالة/الخروج، ومزوّد خدمة الإنترنت، ومعرّفات الجهاز، ومعرّف الإعلان، ونظام التشغيل، وأنواع الوظائف الإضافية، والتاريخ ووقت الوصول، وعدد النقرات، ومعلومات حول استخدام خدماتنا، والبيانات المتعلقة بالأجهزة المتصلة بالشبكة.",
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                      child: Text(
                        "5.2.2.بيانات السجل: وتشمل بيانات سجلات الجهاز وأدوات تحليلات الاستخدام الداخلي، والمنتجات التي شاهدتها أو تبحث عنها، وأوقات استجابة الصفحة، ومدة الزيارات إلى صفحات معينة، ومعلومات تفاعل الصفحة، وبيانات الموقع الجغرافي، وأي رقم هاتف مستخدم للاتصال برقم خدمة العملاء لدينا.",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        "5.2.3.البيانات الجغرافية التقريبية: مثل الدولة والمدينة والإحداثيات الجغرافية، محسوبة على أساس عنوان IP الخاص بك، أو تحديد الموقع الجغرافي من قبل العميل.",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        "5.2.4.بيانات تقنيات التتبع: وتشمل ملفّات تعريف الارتباط (الكوكيز)، وبكسل التتبع، وإشارات الويب لجمع وتخزين بياناتك الشخصيّة ذات الصلة.",
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "5.3.الأطراف الثالثة",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                      child: Text(
                        "5.3.1.بيانات من الشركاء: مثل شركاء التسويق والإعلانات وغيرها من الجهات الأُخرى.",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        "5.3.2.بيانات من شبكات التواصل الاجتماعي: مثل فيسبوك وتويتر وغيرها.",
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "6. أغراض استخدام البيانات",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'يستخدم تطبيق "نقلي" البيانات التي يجمعها للأغراض التالية:',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Text(
                    "6.1.مساعدة المستخدم في إنشاء الحساب، والتحقق من الهوية، وتسجيل الدخول إلى الحساب.",
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Text(
                    "6.2.تعزيز أعمالنا، بما في ذلك تحسين محتوى ووظائف التطبيق، وتقديم خدمة أفضل للعملاء.",
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Text(
                    "6.3.تزويد المستخدم بالدعم الفني، والرد على الأسئلة والاستفسارات ورسائل البريد الإلكتروني.",
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Text(
                    "6.3.تزويد المستخدم بالدعم الفني، والرد على الأسئلة والاستفسارات ورسائل البريد الإلكتروني.",
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Text(
                    "6.4.إرسال الرسائل الإدارية المتعلقة بالخدمة وإبلاغك وتنبيهك ومعلومات حول تحديثات سياسة الخصوصية، أو تأكيدات الحساب، أو تحديثات الأمان، أو النصائح، أو غيرها من المعلومات ذات الصلة.",
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Text(
                    "6.5.تقديم مقترحات وتوصيات للمستخدم بشأن الخدمات والمنتجات التي تهمه بناءً على نشاطه في التطبيق.",
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Text(
                    "6.6.تحسين الخدمات، بما في ذلك عن طريق تخصيص تجربة المستخدم.",
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Text(
                    "6.7.منع الأنشطة المحظورة أو غير القانونية، والامتثال للأنظمة السارية، وفرض شروطنا وأي أغراض أخرى تم الكشف عنها لك في الوقت الذي نجمع فيه معلوماتك أو وفقاً لموافقتك.",
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Text(
                    "6.8.إجراء أبحاث السوق والدراسات الاستقصائية، وللأغراض الإحصائية والبحثية، والتحليلية، والترويجية.",
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "7. مشاركة البيانات",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "7.1.نشارك البيانات الشخصيّة التي نجمعها وفقاً لهذه السياسة مع الشركات التابعة لنا ومع الأطراف الثالثة الأخرى لتحقيق الأغراض المنصوص عليها في القسم [6] من هذه السياسة، وبناءً عليه يجوز لنا مشاركة البيانات في الحالات التالية:",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "7.1.1.بموافقتك: قد نشارك بياناتك إذا منحتنا موافقة محددة على استخدام بياناتك الشخصيّة لغرض محدد.",
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "7.1.2.المصالح المشروعة: قد نشارك بياناتك عندما تكون ضرورية لتحقيق مصالحنا المشروعة.",
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "7.1.3.أداء العقد: قد نشارك بياناتك الشخصيّة للوفاء بشروط عقدنا معك.",
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "7.1.4.الالتزامات القانونية: قد نشارك بياناتك عندما يكون مطلوبًا القيام بذلك بموجب أمر من المحكمة، أو عندما يكون علينا واجب الكشف عن بياناتك أو مشاركتها من أجل الامتثال لأي التزام قانوني.",
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "7.1.5.الاهتمامات الحيوية: قد نشارك بياناتك عندما نعتقد أنه من الضروري التحقيق أو منع أو اتخاذ إجراء بشأن الانتهاكات المحتملة لسياساتنا، أو الاحتيال المشتبه به، أو المواقف التي تنطوي على تهديدات محتملة لسلامة أي شخص وأنشطة غير قانونية، أو كدليل في التقاضي الذي نشارك فيه.",
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '7.1.6.أصحاب الشاحنات: عندما تقدم طلب شراء لأحد مواد الدفان من المناديب المسجلين في تطبيق "نقلي"، فإننا نشارك بعض بيانات المستخدم مع المندوب من أجل تسهيل عملية تنفيذ وتوصيل الطلب.',
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '7.1.7.معالجة المدفوعات: عند إجراء عملية دفع للطلبات من خلال تطبيق "نقلي"، فقد يطلب من المستخدم تقديم بيانات محددة تتعلق بالدفع الإلكتروني لإتمام عملية الدفع، ويوافق المستخدم صراحةً على أنه يحق لنا مشاركة بياناته مع معالجي الدفع لتسهيل عملية الدفع (بما في ذلك على سبيل المثال لا الحصر، مقدّمي خدمات الكشف عن الاحتيال).',
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "7.1.8.العروض التسويقية والترويجية: يجوز لنا مشاركة البيانات مع الكيانات التي تساعدنا في أعمال التسويق والتعريف بخدماتنا والتطوير المستمر وتعزيز تجربته على التطبيق.",
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "7.1.9.نقل الأعمال: في حالة حدوث أيّ انتقال أو تغيير في أعمال مؤسسة بيانات الحاسب، فإنه يجوز لنا مشاركة البيانات مع طرف ثالث فيما يتعلق بأيّ عملية اندماج، أو استحواذ، أو إعادة تنظيم، أو بيع الأصول، أو مشروع مشترك، أو التنازل، أو التحويل، أو أي تصرف مشابه لكل أو جزء من أعمالنا أو أصولنا أثناء المفاوضات، فقد يتم بيع بياناتك أو نقلها كجزء من تلك المعاملة، وللكيان الجديد استخدام البيانات بنفس الطريقة المنصوص عليها في هذه السياسة.",
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "7.2.أنت تمنحنا الحق في السماح لموظفينا وشركاء الأعمال معنا بالتعامل مع بياناتك الشخصيّة في حدود تقديم الخدمات. يرجى ملاحظة أن استخدام أي أطراف ثالثة لبياناتك سيخضع لسياسات الخصوصية الخاصة بها؛ نوصيك بمراجعة سياسات الخصوصية بعناية للأطراف الثالثة.",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "8. تخزين البيانات والاحتفاظ بها",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Text(
                    '8.1.يخزن تطبيق "نقلي" البيانات الشخصيّة للمستخدمين طالما أنها ضرورية لتحقيق الأغراض المحددة في القسم [6]، ويحق لنا الاحتفاظ بها لإعادة النظر في سياسة الخصوصية الحالية، أو عندما تتطلب الأنظمة السارية في بعض الأحيان الاحتفاظ بتلك البيانات لفترة زمنية أطول لأغراض الامتثال للأنظمة التي نخضع لها أو للدفاع عن الدعاوى المرفوعة ضدنا.',
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Text(
                    '8.2.يحتفظ تطبيق "نقلي" بالبيانات المرتبطة بالحسابات في سجلات إلكترونية طالما كان لديك حساب نشط، وتعتمد المعايير التي نحتفظ بها بالبيانات على طول الفترة التي يكون فيها الحساب نشط، وطبيعة وحساسية البيانات الشخصيّة التي نجمعها، ومدة تزويدك بالخدمات، والمُتطلبات القانونيّة السارية، مثل الأوامر الحكومية لأغراض التحقيق أو التقاضي، أو الحماية من دعوى محتملة.',
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Text(
                    '8.3.يحتفظ تطبيق "نقلي" بالبيانات لأغراض التحليل الداخلي، أو لتعزيز الأمان، أو لتحسين وظائف التطبيق، وإنفاذ شروطنا وسياساتنا القانونية، أو لأغراض قانونية وتسويقية ومحاسبية أو لمنع الاحتيال.',
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "9. الإجراءات الأمنية لحماية البيانات",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Text(
                    '9.1.نتخذ كافة التدابير الأمنية اللازمة والمناسبة لحماية البيانات الشخصيّة التي يقدمها المستخدم على تطبيق "نقلي" من الفقد، أو التلف، أو التغيير، أو الإفشاء، أو الوصول غير المسموح به، أو الاستخدام غير المقصود وغير القانوني من خلال بعض الإجراءات الوقائية التي نستخدمها مثل، جدران الحماية، وتشفير البيانات، وعناصر التحكم في الوصول المادي إلى مراكز البيانات لدينا وعناصر التحكم في إذن الوصول إلى البيانات؛ ومع ذلك، أنت تعلم أن الانترنت ليس وسيلة آمنة في جميع الأوقات، ورغم اتخاذنا لمعايير حماية عالية المستوى، إلا أنه من الممكن ألا يكون هذا المستوى من الحماية فعال بنسبة 100% إلا إذا كنت تتبع سياسات أمنية خاصة بك.',
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Text(
                    "9.2.نلتزم بالحفاظ على سرية بياناتك الشخصيّة، ونتعهد في حدود المسموح به قانونًا بعدم استخدامها أو الإفصاح عنها بما يتعارض مع هذه السياسة، ولمساعدتنا في حماية بياناتك الشخصيّة، يجب عليك دائمًا الحفاظ على أمان بيانات حسابك وعدم مشاركتها مع أيّ أحد تحت أيّ ظرف.",
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                  child: Text(
                    "9.3.لن نقوم بتأجير أو بيع بياناتك إلى أيّ أطراف خارجية بأيّ شكل يمكن التعرّف عليك شخصياً من خلالها، ولن نسمح للغير باستخدامها لأغراض التسويق المباشر أو غير المباشر دون الحصول على موافقتك، ولكن يتم استخدام بياناتك للأغراض المعلن عنها في هذه السياسة، ويقتصر استخدامنا لهذه البيانات على الفترة اللازمة لتقديم الخدمات.",
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "10. الإجراءات الأمنية لحماية البيانات",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                      child: Text(
                        "بيانات الدخول للحساب هي مسئولية شخصيّة للمستخدم، وفي حال حصول شخص آخر على تلك البيانات بأي وسيلة واستخدامها للدخول إلى التطبيق وتنفيذ أي معاملات، فإن المستخدم هو المسؤول الوحيد عن ذلك، ولا يتحمل التطبيق أدني مسئولية عما تم من عمليات.",
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "11. تغييرات في بيانات الحساب",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                      child: Text(
                        "من المهم أن تكون البيانات الشخصيّة للمستخدم دقيقة ومحدّثة. يرجى إبقائنا على اطلاع بأي تغييرات تطرأ على بياناتك الشخصيّة خلال فترة تعاملك معنا.",
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "12. الروابط الخارجية",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                      child: Text(
                        '12.1.قد يحتوي تطبيق "نقلي" على روابط تحيل المستخدم أو الزائر إلى تطبيقات أو روابط أو مواقع الكترونية خارجية والتي من شأنها أن تقوم بجمع معلومات عنك والإفصاح عنها بطريقة مختلفة عن هذا التطبيق.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                      child: Text(
                        '12.2.لا يتحكم تطبيق "نقلي" في ممارسات الخصوصية لأي مواقع خارجية، ولا يتحمل المسؤولية القانونية عن المحتوى المنشور على تلك المواقع، أو سياسات الخصوصية لتلك المواقع الخارجية.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                      child: Text(
                        '12.3.يجب على المستخدم مراجعة سياسة الخصوصية وشروط الاستخدام الخاصة بالجهات الخارجية عند زيارة أي روابط خارجية، ويوافق على أن تطبيق "نقلي" لن يكون مسؤولاً عن طريقة الجمع أو الاستخدام أو الإفصاح عن البيانات التي تتبعها أي من الأطراف الخارجية التي لديها رابط في هذا التطبيق.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "13. مسؤوليات المستخدم",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                      child: Text(
                        "13.1.يلتزم المستخدم بتقديم بيانات كاملة وصحيحة ودقيقة، والالتزام بالحفاظ على سرية بيانات الحساب.",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                      child: Text(
                        '13.2.يقر ويوافق المستخدم بأن تطبيق "نقلي" لا يسيطر إلا على البيانات التي يجمعها من خلاله، ولا يملك أي سيطرة على أي بيانات يقدمها المستخدم خارج التطبيق.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                      child: Text(
                        '13.3.لن يتحمل تطبيق "نقلي" مسؤولية فشل المستخدم في الحفاظ على خصوصيته أو سرية بياناته.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '13.4.يقع على المستخدم دور كبير في حماية بياناته الشخصيّة، وذلك من خلال ما يلي:',
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '13.4.1.الاطلاع والتحكم أو تعديل المعلومات التي تحدد الهوية من خلال حسابه في التطبيق.',
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '13.4.2.عدم الإفصاح عن بيانات حسابه لأيّ شخص آخر، وعلى الأخص بيانات الدخول للحساب.',
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                      child: Text(
                        '13.4.3.تسجيل الخروج بعد انتهاء الجلسة عند استخدام جهاز لشخص آخر أو الإنترنت في الأماكن العامة.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "14. ملفّات تعريف الارتباط (الكوكيز)",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                      child: Text(
                        '14.1.يستخدم تطبيق "نقلي" خاصية الكوكيز للعمليات الأساسية مثل تصفّح التطبيق، وتقديم الإعلانات التي تناسب اهتمامات المستخدمين، بالإضافة إلى أغراض التسوق وغيرها، وبإمكانك تغيير إعدادات الكوكيز من خلال الخطوات التالية:',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 10),
                      child: Text(
                        '14.1.1.ضبط متصفّحك لإعلامك عند تلقّي واستلام ملفّات الكوكيز.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 10),
                      child: Text(
                        '14.1.2.ضبط متصفّحك لرفض أو قبول ملفّات الكوكيز.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 10),
                      child: Text(
                        '14.1.3.تصفّح التطبيق باستخدام خاصية الاستخدام المجهول للمتصفّح.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 10),
                      child: Text(
                        '14.1.4.حذف ملفّات الكوكيز بعد زبارتك للتطبيق.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 10),
                      child: Text(
                        '14.2.يمكنك تعطيل عمل ملفّات الكوكيز، ولكن قد يؤدي إلى منع عرض بعض صفحات التطبيق أو عرضها بشكل غير دقيق.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "15. تعديلات سياسة الخصوصية",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                      child: Text(
                        '15.1.تمتلك مؤسسة بيانات الحاسب الحق الكامل في إجراء تعديلات على هذه السياسة في أي وقت لتتضمن الممارسات السائدة في تطبيق "نقلي" أو لتلبية المتطلبات القانونية، وستدخل هذه التعديلات والتوضيحات حيز التنفيذ فور نشرها على التطبيق.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 10),
                      child: Text(
                        '15.2.إذا قمنا بإجراء تغييرات جوهرية على هذه السياسة، سنقوم بإعلامك -إذا كان ممكناً- بأنه قد تم تحديثها، وسيتم نشر هذه التعديلات على هذه الصفحة وتحديث تاريخ السريان المذكور أعلاه، حتى تكون على دراية بالمعلومات التي نجمعها، وكيفية استخدامها، وتحت أي ظروف، إن وجدت، سنقوم باستخدامها أو الكشف عنها.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 10),
                      child: Text(
                        '15.3.ننصح جميع المستخدمين بمراجعة وقراءة هذه السياسة بشكل منتظم للاطلاع على تعديلاتها، يرجى العلم بأننا لن نتحمل مسؤولية عدم مراجعتك هذه السياسة قبل استخدام التطبيق، وأن قراءة هذه السياسة من قبل مستخدمي تطبيق "نقلي" هو إقرار كامل واعتراف منهم بكل ما ورد بهذه السياسة وموافقة على جميع ما ورد فيها.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "16. الموافقة على سياسة الخصوصية",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                      child: Text(
                        '16.1.يقر المستخدم بأنه قرأ سياسة الخصوصية هذه، ويوافق على الالتزام بجميع بنودها وشروطها.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 10),
                      child: Text(
                        '16.2.يوافق المستخدم بأن استخدامه لتطبيق "نقلي" أو خدماته يشير إلى موافقة صريحة على هذه السياسة والشروط التي تحكم استخدام هذا التطبيق.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "17. الأسئلة والتعليقات",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                      child: Text(
                        'إذا كانت لديك أية أسئلة أو استفسارات حول سياسة الخصوصية هذه، يرجى التواصل معنا على:',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 10),
                      child: Text(
                        'البريد الإلكتروني: 	Sales@naqlee.com',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 10),
                      child: Text(
                        'حقوق الطبع والنشر © نقلي 2024',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 10),
                      child: Text(
                        'جميع الحقوق محفوظة لـ مؤسسة بيانات الحاسب',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "شروط الاستخدام لتطبيق نقلي",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "المقدمة",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'المقدمةتحكم شروط الاستخدام هذه ("الشروط") وصولك واستخدامك لتطبيقات "نقلي" على أنظمة ANDROID وIOS (يمكنك تحميله من متاجر جوجل بلاي وآبل ستور) وكافة الصفحات والمحتوى والمعلومات والأدوات والخدمات المتاحة من خلالها ("نقلي")، وهي خدمة تقدمها مؤسسة بيانات الحاسب المسجلة بموجب الأنظمة السعودية، ورقم السجل التجاري [2050180086]، ومقرها الرئيسي [الخرج، طريق الملك عبدالله].يجب أن تقرأ هذه الشروط وسياسة الخصوصية وكافة السياسات المكملة قبل الوصول إلى تطبيق "نقلي" أو استخدامه، إذا كنت لا توافق على هذه الشروط، من فضلك لا تدخل أو تسجل أو تستخدم هذا التطبيق.تشير هذه الشروط إلى سياسة الخصوصيّة والتي تحدّد الممارسات التي نعتمدها لمعالجة أيّ بيانات شخصيّة نجمعها منك أو تزوّدنا بها. أنت توافق على هذه المعالجة وتؤكّد بأنّ كافة البيانات التي تزوّدنا بها صحيحة.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "التعريفات",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "في هذه الشروط، وما لم يقتضِ السياق خلاف ذلك، يكون للمصطلحات التالية المعاني المشار إليها: ",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '"نقلي": يقصد به تطبيقات "نقلي" لأنظمة ANDROID وiOS وHarmonyOS.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '"نحن"، "ضمير المتكلم" أو "ضمير الملكية": يقصد بها مؤسسة بيانات الحاسب.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '"الحساب": يقصد به حساب المستخدم في تطبيق "نقلي"، والذي يمكنه من الاستفادة من خدماته.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '"المستخدم" أو "أنت" أو "ضمير الملكية للمخاطب": يقصد به كل من يزور تطبيق "نقلي"، أو يُسجل حساب، أو يستخدم التطبيق سواء كان مقدم خدمة أو عميل.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '"المندوب": يقصد به كل من يسجل حساب في تطبيق "نقلي" (أصحاب الشاحنات) لبيع الدفان المخصص لأعمال البناء والمقاولات، ويشار له في هذه الشروط بلفظ الجمع: (المناديب).',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '"العميل": يقصد به كل من يسجل حساب في تطبيق "نقلي" لطلب الدفان من خلال التطبيق، ويشار له في هذه الشروط بلفظ الجمع: (العملاء).',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '"الطرفين": يقصد به المندوب والعميل.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '"المواد": يقصد بها أنواع الدفان التي تستخدم في أعمال البناء والمقاولات.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '"الطلب": يقصد به تقديم طلب من العميل إلى المندوب لشراء كمية من الدفان.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '3.10."القوانين": يقصد بها الأنظمة السارية في المملكة العربية السعوديّة.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '3.11."الشروط والأحكام": يقصد بها هذه الشروط وما تتضمنه من بنود إلى جانب سياسة الخصوصية.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "حساب المستخدم",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'من أجل استخدام تطبيق "نقلي"، يجب على المستخدم تسجيل حساب، وأن يوافق على:',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'التسجيل بالاسم الحقيقي، وألا يستخدم اسم مستعار أو مجهول أو مضلل، وفي حالة التسجيل نيابة عن كيان تجاري فيجب تقديم المستندات التي تثبت تفويض من يسجل الحساب أو يستخدم التطبيق بموجب وكالة شرعية عامة أو تفويض مصدّق من الغرف التجارية، ويقر بتحمل مسؤولية استخدام تطبيق "نقلي".',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'تقديم بيانات صحيحة ودقيقة وكاملة، والالتزام بتحديثها إذا طرأ عليها أيّ تغيرات.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'الحفاظ على سرية بيانات حسابه، وتحمل مسؤولية الإفصاح عن هذه البيانات لأي طرف ثالث.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'تقييد الغير من استخدام بيانات حسابه وبالأخص كلمة المرور.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'تحمل المسؤولية عن الأنشطة التي تحدث من خلال حسابك وكلمة المرور.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'التعاون مع إدارة التطبيق عند طلب أي معلومات إضافية للتحقق من هويته.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'الإبلاغ بأي استخدام غير قانوني للحساب أو تعرضه للاختراق أو أي اشتباه في استخدامه.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'يتحمّل المستخدم كامل المسؤولية عن أي بيانات أو معلومات مزيفة أو غير صحيحة يقدمها للتطبيق.يحتفظ تطبيق "نقلي" بحقه الكامل في القيام بعمليات التحقق اللازمة للتأكد من متطلبات التسجيل، وبمجرد إتمام التسجيل بنجاح، يستمر تسجيلك لفترة غير محددة ما لم يتم تعليقه أو إلغائه كما هو محدد في هذه الشروط.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "التأكيدات والضمانات",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'بمجرد تسجيل حساب في تطبيق "نقلي" وفقاً لأحكام التسجيل الواردة في البند أعلاه، فأنت تتعهد بما يلي:',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'أنك تستوفي شروط صلاحية وأهلية التسجيل، والوفاء بكافة الالتزامات تجاه تطبيق "نقلي".',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'قبول شروط الاستخدام وسياسة الخصوصية، والموافقة على الالتزام بكافة بنودها.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'عدم القيام بأي تصرف من شأنه التأثير بشكل سلبي على عمل التطبيق أو سمعته أو مصالحه.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'عدم استخدام تطبيق "نقلي" لأي سبب قد يتناقض أو يتعارض مع أهدافه وسياساته، أو القوانين السارية.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'عدم نقل الحساب إلى مستخدم آخر أو أي طرف آخر دون الحصول على موافقة خطية مسبقة من قبلنا.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'سياسة الطلب',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '"نقلي" تطبيق إلكتروني يمكنك تحميله من متاجر جوجل بلاي وآبل ستور تملكه وتديره مؤسسة بيانات الحاسب، يساعد العملاء على طلب مواد الدفان بكافة أنواعها من المناديب المسجلين في التطبيق وتوصيلها إلى العميل.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'يسمح تطبيق "نقلي" للعملاء بتقديم طلبات لأنواع الدفان، وتحديد الموقع بشكل دقيق، وبعد ذلك يظهر الطلب للمناديب (أصحاب الشاحنات).',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'يحدد كل مندوب سعر الدفان بناءً على نوع الدفان، والكمية المطلوبة، والموقع الذي حدده العميل، والمسافة.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'يختار العميل سعر الدفان المناسب والتواصل مع المندوب من خلال التطبيق للاتفاق على تفاصيل الطلب (نوع الدفان، والكمية المطلوبة، وموقع الاستلام، والمسافة) وتحديد طريقة الدفع.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'يلتزم العميل بتحديد بيانات الطلب بشكل صحيح، ومكان توصيل الطلب، والشخص المفوض بالاستلام، ويتم توصيل الطلب مباشرة إلى العنوان المحدد من العميل.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'يلتزم العميل بدفع قيمة الطلب من خلال أحد الوسائل التي يوفرها التطبيق.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'في حالة قبول المندوب، يدخل الطرفان في علاقة تعاقدية مباشرة وملزمة قانونًا، ويلتزم بتوصيل الطلب إلى الموقع المحدد من العميل.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'يلتزم المندوب بإبلاغ إدارة تطبيق "نقلي" في حالة تعذر شحن المواد إلى العميل لأيّ سبب.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'يقر المندوب بتحمل المسؤولية الكاملة عن أخطاء الأشخاص التابعين له أو الأشخاص الذين يستعين بهم في عملية توصيل الطلبات.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '6.10.يوافق الطرفين على أن الوسيلة الرسمية والمعتمدة للتواصل تكون من خلال نظام الشات الذي يوفّره تطبيق "نقلي"، وبالتالي يحظر الاتفاق على إبرام أيّ طلبات خارج نطاق التطبيق، وفي حالة مخالفة هذا الالتزام فإنه يحق لإدارة تطبيق "نقلي" تعليق الحساب المخالف سواء بشكل دائم أو مؤقت.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '6.11.يقتصر دور تطبيق "نقلي" على الربط بين المندوب والعميل مقابل عمولة عن كل طلب، ومن المعلوم للطرفين بأن تطبيق "نقلي" لا يقوم – سواء بشكل مباشر أو غير مباشر - ببيع أو طلب أو توصيل مواد الدفان، وإنما يعد وسيط بين المندوب والعميل.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '6.12.يقر العميل بأنه متعاقد مستقل مع المندوب فيما يتعلق بالطلب، وأن تطبيق "نقلي" لا يقدم أي ضمانات أو تعهدات فيما يتعلق بالأسعار وعملية التوصيل، ولا يسأل عن أفعال أصحاب الشاحنات.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '6.13.يقر المندوب بأن تطبيق "نقلي" مجرد وسيط ينتهي دوره بمجرد قبول طلب العميل، وتنصرف كافة الالتزامات المتعلقة بموضوع الطلب إلى طرفيه فقط لا غير.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'سياسة الدفع',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'يوفّر تطبيق "نقلي" الدفع الإلكتروني من خلال سداد، وآبل باي، أو الدفع نقداً.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'في حالة الدفع الإلكتروني، يجب إضافة البيانات بشكل صحيح، وتكون المبالغ مستحقة بشكل فوري بمجرد إتمام عملية الدفع، وسيصلك إشعار بتأكيد الدفع على البريد الإلكتروني المسجل لدينا خلال 24 ساعة، وفي حالة رفض عملية الدفع، فسيتم إبلاغك بالمشكلة، ويمكنك استخدام وسيلة دفع بديلة.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'يوافق المستخدم على تحمل كافة رسوم عملية الدفع.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'تحتفظ مؤسسة بيانات الحاسب بالحق في تعديل سياسة الدفع في أيّ وقت وفقًا لما تراه مناسبًا وذلك من خلال إضافة وسائل دفع جديدة أو إلغاء أيّ وسيلة حالية.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'سياسة الرسوم والعمولة',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'تسجيل الحساب في تطبيق "نقلي" بدون رسوم، ويحق لنا فرض رسوم مستقبلاً إذا رأينا ضرورة لذلك.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'يحصل تطبيق "نقلي" على عمولة من العميل قدرها 5٪ من السعر الاجمالي للطلب عن كل طلب يقدم من خلاله.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'يقر ويتعهد العميل بدفع العمولة المستحقة لتطبيق "نقلي".',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'عمولة تطبيق "نقلي" غير قابلة للاسترجاع بعد اتمام الاتفاق بين الطرفين، وفي حال نشوب أي خلافات لاحقة يتحمل الطرفين نتيجة ذلك.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'تراخيص وقيود الاستخدام',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'تمنحك مؤسسة بيانات الحاسب بموجب هذه الشروط ترخيصاً محدوداً شخصياً غير حصري وغير قابل للتحويل وغير قابل للترخيص من الباطن من أجل تنزيل نسخة من التطبيق على جهازك الذي تملكه أو تتحكم فيه، والوصول إلى المحتوى والمعلومات والمواد ذات الصلة للاستخدام الشخصي وبما يتوافق مع هذه الشروط.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'نصرّح للمستخدم بالاستخدام المحدود لهذا التطبيق. ويحظر أي استخدام يتجاوز الاستخدامات المسموح بها، فلا يجوز:',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '9.2.1.استخدام التطبيق لانتهاك أي من القوانين السارية، أو التسبب في أضرار أو خسائر لنا.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '9.2.2.ترخيص، أو تأجير، أو بيع، أو نقل، أو توزيع، أو تخصيص، أو استضافة، أو استغلال الخدمة تجارياً.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '9.2.3.فحص أو محاولة استكشاف قوة أو ضعف النظام الأمني للتطبيق، أو اختراق أو محاولة اختراق النظام الأمني للتطبيق، أو التحايل على ميزات التطبيق المتعلقة بالأمان أو تعطيلها أو التدخل فيها بطريقة أخرى.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '9.2.4.محاولة فك رموز، أو برمجة، أو تشفير، أو عكس هندسة أي من البرامج المستخدمة لتوفير التطبيق.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '9.2.5.إعادة إنتاج، أو نسخ، أو بيع، أو إعادة بيع أي جزء من التطبيق، أو استخدامه بصورة مغايرة لأغراض الاستغلال التجاري دون الحصول على موافقة كتابية صريحة منا.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '9.2.6.انتحال شخصية أيّ مستخدم أو كيان، بما في ذلك أيّ موظف أو ممثل لتطبيق "نقلي".',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '9.2.7.استخدام أي علامات وصفية أو نصوص مخفية للعلامة التجارية "نقلي".',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '9.2.8.نشر أو إرسال محتوى غير مرغوب فيه أو غير مصرح به، بما في ذلك المواد الإعلانية أو الترويجية أو "البريد غير الهام" أو "البريد العشوائي" أو "الرسائل المتسلسلة" أو "المخططات الهرمية" أو أيّ شكل آخر.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '9.2.9.نشر، أو نقل، أو إرسال، أو تحميل، سواء بقصد أو دون قصد، أو أية مواد تحتوي على فيروسات أو "أحصنة طروادة" أو "ديدان" أو "قنابل موقوتة" حاسوبية أو أحد برامج رصد لوحة المفاتيح، أو برامج التجسس، أو البرامج المدعومة إعلامياً، أو أي من البرامج الضارة الأخرى، أو أي من الرموز المماثلة التي تهدف إلى التأثير سلباً على تشغيل أي من برامج أو أجهزة الحاسوب.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '9.2.10.إزالة أو إتلاف أيّ من حقوق الطبع والنشر أو العلامات التجارية أو الملكية في تطبيق "نقلي".',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '9.2.11.انتهاك قوانين حقوق النشر، أو العلامة التجارية، أو براءة الاختراع، أو الإعلان، أو قواعد البيانات، أو أي من حقوق الملكية الفكرية التي تتعلق بنا أو المرخصّة لنا أو التي تتعلق بالغير.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'لا يشمل الترخيص الممنوح لك أيّ حقوق ملكية على تطبيق "نقلي" أو جزء منه، كما لا يشير هذا الترخيص بشكل مباشر أو غير مباشر لوجود شراكة من أيّ نوع بينك وبيننا فيما يتعلق باستخدامك للتطبيق.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'تنتهي التراخيص الممنوحة لك من قِبلنا إذا لم تلتزم بشروط الاستخدام هذه.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'إخلاء المسؤولية',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '10.1.يتم توفير تطبيق "نقلي" ومحتواه وخدماته والمعلومات المرتبطة به على أساس ثابت "كما هو" و "كما هو متاح" دون أي ضمانات أو كفالات من أي نوع سواء صريحة أو ضمنية، ويجوز لإدارة تطبيق "نقلي" إجراء أية تغيير، أو تحديث لأي محتوى، أو مادة، أو خدمة على التطبيق.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '10.2.تخلي مؤسسة بيانات الحاسب مسؤوليتها عن كافة الضمانات من أي نوع (صريحة، أو ضمنية، أو قانونية) فيما يتعلق بهذا التطبيق، بما في ذلك على سبيل المثال لا الحصر، التسويق، أو ملاءمة الاستخدام، أو أي غرض معين.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '10.3.لا تضمن مؤسسة بيانات الحاسب إتاحة تطبيق "نقلي" في الوقت المحدد بشكل تام وآمن، وعلى الرغم من أننا نسعى لبذل قصارى جهدنا لضمان توافره للاستخدام على مدار الساعة، إلا أنه قد يكون التطبيق غير متوفر من وقت لآخر بسبب أعمال الإصلاح والصيانة الدورية أو التطوير أو بسبب المشكلات الفنية.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '10.4.لن يتحمل تطبيق "نقلي" مسؤولية الخسائر، أو الأضرار المباشرة، أو غير المباشرة، أو التبعية، أو العرضية الناتجة عن:',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '10.4.1.خطأ العميل في تحديد نوع وكمية الدفان المطلوبة من المندوب.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '10.4.2.خطأ المندوب أثناء توصيل الطلب.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '10.4.3.عدم توافق الدفان مع أعمال الحفريات والأساسات، أو تحقيق الغرض منه.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '10.4.4.تأخر توصيل الطلبات من قبل المندوب.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '10.4.5.كافة التعاملات التي تتعلق بالطلب بما في الالتزامات المالية.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '10.4.6.خسارة الأرباح، أو المبيعات، أو الأعمال، أو الإيرادات، أو توقف الأعمال أو ما شابه.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '10.4.7.تقصير المستخدم في الحفاظ على أمان وسرية وخصوصية بيانات الحساب.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '10.4.8.الأمور الخارجة عن الإرادة، مثل تعطُل المعدات والأجهزة أو الاتصالات الخاصة بتشغيل التطبيق.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '10.4.9.أيّ روابط خارجية يُمكنك الوصول إليها من خلال التطبيق، أو أيّ محتوى مقدم على هذه الروابط.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '10.5.لا يضمن تطبيق "نقلي" بأن الإعلانات، أو محتواها، أو صورها، أو أسعارها ستكون دقيقة أو كاملة أو موثوقاً بها أو خالية من الأخطاء، ويتحمل المعلن مسؤولية مراجعة محتوى إعلاناته للتأكد من دقتها وصحتها.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '10.6.صمم تطبيق "نقلي" بطريقة آمنة وباستخدام أحدث نُظم التشفير لضمان أمان وسرية البيانات، وحيث أنه لا يوجد نظام آمن بنسبة 100%، إلا أنه لن يتحمل تطبيق "نقلي" أية مسؤولية عن أي فيروس أو تلويث أو ميزات مدمرة قد تؤثر على جهاز الجوال نتيجة لاستخدامك أو الوصول أو الانقطاع عن أو عدم القدرة على استخدام التطبيق. ',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '10.7.بصفتك مستخدم لتطبيق "نقلي"، فأنت توافق على أن المعلومات التي ترسلها لنا صحيحة ودقيقة، ويوافق الطرفين على تحمل مسؤولية البيانات والمعلومات التي يرسلها أو يستلمها كل طرف من خلال التطبيق.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '10.8.يقر المستخدم بأن تطبيق "نقلي" مجرد وسيط بين الطرفين، وينتهي دوره بقبول وإتمام إجراءات الطلب، وتنصرف كافة الالتزامات المتعلقة بموضوع تنفيذه إلى الطرفين فقط لا غير.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '10.9.قد نقوم في أي وقت بتعديل أو وقف أو قطع خدمات تطبيق "نقلي" بدون إرسال إخطار إليك بذلك، كما قد نقوم بوقف استخدامك للتطبيق إذا قمت بانتهاك هذه الشروط أو إذا أسأت استخدامه من وجهة نظرنا.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '10.10.مع عدم الإخلال بحقوق تطبيق "نقلي" الأخرى، فإنه يحق لإدارة التطبيق إيقاف أو إلغاء حساب أي مستخدم، أو تقييد وصوله إلى التطبيق في أي وقت وبدون إشعار ولأي سبب، ودون تحديد.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'حقوق الملكية الفكرية والعلامة التجارية',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '11.1.تحتفظ مؤسسة بيانات الحاسب بجميع الحقوق والملكية والمصلحة في تطبيق "نقلي" والأفكار المُعبَر عنها داخله والأجهزة والبرامج والعناصر الأخرى المستخدمة لتوفيره، وحقوق النسخ وبراءات الاختراع وحقوق العلامات والأسرار التجارية والمظهر التجاري والتصاميم، والمحتوى والنصوص والرسومات والأشكال والخطوط والصور ومقاطع الصوت والفيديو والمواد الرقمية، ومجموعات البيانات والبرمجيات وحقوق البرمجة والرموز الأخرى التي يحتوي عليها التطبيق، وهي محمية بموجب قوانين الملكية الفكرية والعلامات التجارية.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '11.2.الشعارات والكلمات ورؤوس الصفحات وأيقونات الأزرار والأسماء الخدمية المرتبطة بتطبيق "نقلي" هي علامات تجارية وتصميمات تجارية تملكها مؤسسة بيانات الحاسب، ولا يجوز لك إعادة إنتاجها أو استخدامها بأي مكان لأغراض ترويجية سواء بقصد أو عن غير قصد، وأي أسماء أو علامات تجارية أو علامات خدمة تتعلق بالغير، هي ملك لأصحابها المعنيين.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '11.3.يعد أيّ استخدام غير مصرح به أو نسخ أو تقليد أو تشويه للعلامة التجارية "نقلي" انتهاكًا لحقوقنا الواردة في قوانين حماية العلامات التجارية.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '11.4.لا يرد في هذه الشروط أو في محتوى التطبيق ما يمكن تفسيره على أنه يمنح بشكل صريح، أو ضمني، أي ترخيص أو حق في استخدام العلامات التجارية لتطبيق "نقلي" دون الحصول على موافقة مسبقة منا.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'التعويضات',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '12.1.أنت توافق على تعويض مؤسسة بيانات الحاسب وأي من مسؤوليها وموظفيها ووكلائها عن أي خسائر، أو أضرار، أو مطالبات، أو دعاوى، أو غرامات، أو تكاليف، أو التزامات، أو نفقات أياً كان نوعها أو طبيعتها بما في ذلك الرسوم القانونية وأتعاب المحاماة، والتي تنشأ عن:',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '12.1.1.أيّ ادعاءات أو مطالبات ناتجة عن استخدامك للتطبيق.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '12.1.2.إساءة الاستخدام، أو الاستخدام غير القانوني لتطبيق "نقلي" مهما كان نوعه.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '12.1.3.التزييف في البيانات أو المعلومات التي يقدمها المستخدم لنا.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '12.1.4.تعطل أو توقف التطبيق عن العمل؛ أو عدم تحديثه.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '12.1.5.انتهاكك أو عدم التزامك بشروط الاستخدام وسياسة الخصوصية لتطبيق "نقلي".',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '12.1.6.انتهاكك أيّ من الأنظمة السارية، بما في ذلك قوانين حماية البيانات.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '12.1.7.التعدي على حقوق الملكية الفكرية (حقوق النشر والعلامات التجارية) أو حقوق أخرى للآخرين.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '12.2.يستثني تطبيق "نقلي" من ضماناته وبنوده وشروطه أي خسائر مالية قد تلحق بالمستخدم، أو تشويه في السمعة، أو أي أضرار خاصة تنشأ عن سوء استخدامه، ولا يتحمل التطبيق أي مسئوليات أو مطالبات في مثل هذه الحالات.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '12.3.لن يكون تطبيق "نقلي" ومسئوليه وموظفيه مسؤولين قانونًا تجاهك أو تجاه أي طرف آخر عن أي خسارة مباشرة أو غير مباشرة أو عن أي تكلفة أخرى قد تنشأ عن أو فيما يتصل بتنفيذ هذه الشروط، أو تقديم الخدمة.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '12.4.يحب على المستخدم حماية تطبيق "نقلي وتابعيه وأن يدافع عنهم ويعوضهم عن أية خسائر ناتجة عن أية دعوى أو مطالبة تتعلق بالتطبيق أو ناتجة عن عمل أو إهمال من قِبل المستخدم أو ممثليه أو وكلائه.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '12.5.يجب على المستخدم تعويضنا عن أي خسائر أو أضرار قد تلحق بالتطبيق نتيجة أي استخدام غير شرعي أو غير مفوض من قِبلنا.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'الروابط الخارجية',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '13.1.قد يحتوي تطبيق "نقلي" على روابط لمواقع أخرى تديرها أطراف أخرى غير مؤسسة بيانات الحاسب، نحن لا نؤيد هذه الروابط، ولن نتحمل مسؤولية المحتوى أو المعلومات أو أي مواد أخرى تتوفر على هذه المواقع، وفي حال قررت الوصول إلى أيّ مواقع أخرى، فأنت المسؤول الوحيد عن ذلك.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '13.2.لا تشكل الروابط الموجودة على تطبيق "نقلي" موافقة منا على استخدام مثل هذه الروابط، ولا يقدم تطبيق "نقلي" أيّ ضمانات أو تعهدات أياً كان نوعها فيما يتعلق بهذه الروابط الخارجية وما يتعلق بها.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '13.3.يرجى مراجعة سياسات الخصوصية لمواقع الأطراف الأخرى قبل استخدامها وتقديم بياناتك لها.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'الاتصالات الإلكترونية',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '14.1.قد نتواصل مع المستخدم عن طريق البريد الإلكتروني المسجل في تطبيق "نقلي" فيما يتعلق بتحديثات هذه الشروط والخصوصية، والرسائل الإدارية والإشعارات الفنية وتنبيهات الأمان، ويوافق المستخدم على أن كل الاتصالات الإلكترونية تستوفي كافة الشروط وتفي بجميع المتطلبات القانونية كما لو كانت هذه الاتصالات مكتوبة.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '14.2.قد نتواصل مع المستخدم لأغراض ترويجية، فيما يتعلق بأي تغييرات أو ميزات أو أنشطة جديدة تضاف إلى التطبيق. في حال قرر المستخدم في أي وقت عدم استقبال أو استلام مثل هذه الاتصالات، يمكنه إيقاف استلام هذه الرسائل بالنقر على رابط إلغاء الاشتراك أسفل الرسالة الإلكترونية.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'المدة والإنهاء',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '15.1.تكون مدة هذه الشروط محددة بفترة تسجيلك حساب واستخدامك للتطبيق، وتظل سارية ما لم يتم إنهاؤها من طرفنا أو طرفك.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '15.2.يحق لـ مؤسسة بيانات الحاسب إنهاء هذه الشروط على الفور، في حال توفر أي من الحالات التالية:',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '15.2.1.انتهاك هذه الشروط، أو سياسة الخصوصية، أو قواعد استخدام تطبيق "نقلي".',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '15.2.2.إذا ثبت لنا إساءتك باستخدام التطبيق، أو تسبب استخدامك لتطبيق "نقلي" بأيّ مشكلات قانونية لنا.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '15.3.يحق للمستخدم إنهاء هذه الشروط في أيّ وقت عن طريق التوقف عن استخدام التطبيق أو إلغاء تثبيته من على الجوال؛ وعند الإنهاء أو الإلغاء، ستتوقف كافة التراخيص الممنوحة للمستخدم بموجب هذه الشروط.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'التعديلات في الشروط',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '16.1.يحق لـ مؤسسة بيانات الحاسب تعديل، أو تحديث، أو إكمال، أو استبدال، أو حذف أي شرط من هذه الشروط، ويلتزم المستخدم بالتعديلات التي تجريها وتراها لازمة.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '16.2.تسري جميع التعديلات فور نشرها على تطبيق "نقلي"، وتنطبق على كل استخداماتك بعد ذلك.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '16.3.يحق لـ مؤسسة بيانات الحاسب تغيير أو تعليق أو إيقاف الخدمة التي تقدمها من خلال تطبيق "نقلي"، أو إجراء تعديلات أو تحسينات على التطبيق أو إضافة بعض الميزات لزيادة فاعليته، ويلتزم المستخدم بأية توجيهات أو تعليمات يقدمها تطبيق "نقلي" إليه في هذا الخصوص.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'التعديلات في الشروط',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '17.1.تخضع وتفسر هذه الشروط وفقًا للقوانين السارية في المملكة العربية السعوديّة.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '17.2.إذا وجدت محكمة أو جهة حكومية ما في المملكة العربية السعوديّة أن أي جزء من الشروط غير قابل للتنفيذ أو غير ساري، فيعتبر هذا الجزء قابلاً للفصل ومحذوفًا من هذه الشروط، وستظل بقية البنود سارية المفعول.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'تحويل الحقوق والالتزامات',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '18.1.يحق لـ مؤسسة بيانات الحاسب تحويل أو نقل كافة حقوقها أو التزاماتها المنصوص عليها في هذه الشروط إلى أيّ طرف ثالث دون اعتراض منك بشرط أن يوافق هذا الطرف الثالث على الالتزام بهذه الشروط.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '18.2.يحظر على المستخدم التنازل عن كل أو أي من التزاماته أو حقوقه بموجب هذه الشروط إلى أيّ طرف ثالث، أو أن تفويض أي طرف آخر بخلاف ما هو مسموح بإدارة حسابه دون موافقة كتابية وصريحة منا.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'القوة القاهرة',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'لن تتحمّل مؤسسة بيانات الحاسب مسئولية أيّ تأخير أو إخفاق في أداء أيّ من التزاماتها بموجب هذه الشروط متى كان ذلك ناتجاً عن القوة القاهرة أو الظروف الطارئة والتي تؤدي إلى تعطيل عمل التطبيق بشكل طبيعي.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'علاقة الأطراف',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'لن تفسّر بنود هذه الشروط بوجود علاقة شراكة أو مشروع مشترك أو وكالة بين مؤسسة بيانات الحاسب وبين أي مستخدم (سواء كان مندوب أو عميل) أو أي طرف ثالث، ولا يحق لأي طرف إلزامنا بأيّ شيء وبأي شكل.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'التعارض',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'في حال تعارضت هذه الشروط مع أيّ من إصدارات سابقة لها، فإنّ النسخة الحالية تكون هي السائدة.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'الإخطار',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'يجوز لتطبيق "نقلي" إرسال إخطار للمستخدم من خلال إشعارات التطبيق، أو البريد الإلكتروني المسجل.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'اللغة',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'كُتبت هذه الشروط باللغة العربيّة، وفي حال تُرجمت إلى لغة أجنبيّة أخرى فإنّ النص العربي هو الذي يُعتد به.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'الاتفاق الكامل',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'تشكل هذه الشروط وسياسة الخصوصية (أو النسخ المعدّلة) كامل الاتفاق بينك (المندوب والعميل) وبين تطبيق "نقلي" الصادر عن مؤسسة بيانات الحاسب، وتحل محل أيّ إصدارات سابقة من هذه الشروط.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'التواصل معنا',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'إذا كان لديك أي أسئلة بشأن هذه الشروط، أو الممارسات المتعلقة بتطبيق "نقلي"، فلا تتردد في التواصل معنا على: البريد الإلكتروني: info@raml.saحقوق الطبع والنشر © "نقلي" 2024جميع الحقوق محفوظة لـ مؤسسة بيانات الحاسب',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "This Privacy Policy sets out the basis on which we will handle any personal data, including but not limited to payment information and other data that we collect from you or from other sources or that you provide to us (“Data”) in connection with your access and use of our website and/or Naqlee mobile application (collectively, the “Site”), services and applications (collectively, the “Services”). We understand the importance of this data and are committed to protecting and respecting your privacy. Please read the following carefully to understand our data practices. By using our Services, you agree to handle data in accordance with this Privacy Policy.",
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "References to “we” (or similar) in this Privacy Policy are references to Computer Data Corporation (Naqlee) and references to “you” or “user” are references to you as an individual or legal entity, as applicable",
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Naqlee Application Terms of Use",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "1. Introduction",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                        child: Text(
                          "a. These terms set out the rules governing your use of the Naqlee application. By using the application, you agree to be bound by these terms.",
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "2. Modifications to the terms",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                        child: Text(
                          "a. We reserve the right to modify these terms at any time. You will be notified of any changes via the application or by email.",
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "3. Permitted Use",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(40, 8, 8, 0),
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "a. The application must be used only for lawful purposes.",
                                  textAlign: TextAlign.left,
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "b. The application must not be used for fraudulent or abusive purposes.",
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "4. Account Creation",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "a.  You must create an account to use the application services.",
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "b.  You are responsible for maintaining the confidentiality of your account information.",
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "5. Services Provided",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                        child: Text(
                          "a. The Naqlee application provides transportation services, and you must comply with all instructions while using the service.",
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "6. Fees and Payment",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "a.  Fees may be imposed for transportation services.",
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "b.  All payments must be made through approved payment methods.",
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "c.  The customer must pay the dues and any breach or change thereof and all payments must be made through approved payment methods.",
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "7. Liability",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                            child: Text(
                              "a. Naqlee is not responsible for any damages resulting from the use of the application and during the transportation process and what happens between the carrier and the customer or the inability to use it.",
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                            child: Text(
                              "b. Naqlee is an intermediary institution between the carrier and the customer only. The carrier is obligated to provide the service in the required manner and not to tamper with or neglect the property and must preserve it. The user is obligated to provide the correct information to the carrier and also provide it through the Naqlee application or website.",
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "8. Termination of use",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                        child: Text(
                          "a. We may terminate or suspend your account at any time if you violate these terms or the terms governing the country in which you operate.",
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "9. Applicable law",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "a. These terms are subject to applicable laws.",
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "10. Financial transactions",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                        child: Text(
                          "a. Naqlee is a platform for connecting customers and users and has the right to take a commission as it deems appropriate with the requirements of the work. This may include a deduction from the amount for partners due to bank transfer fees.",
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "11. Contact us",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "a. If you have any questions regarding these terms, you can contact us via [sales@naqlee.com].",
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 30, 8, 8),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "1. What data may we collect from you?",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "We may collect and process the following data:",
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                            child: Text(
                              "a. Data that you provide by filling in forms on the Site, including data provided when registering to use the Site and other shared registrations (for example, social media logins), subscribing to our services, posting material or requesting other services.",
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                            child: Text(
                              "b. Data that you provide when entering a competition or promotion on our Site, completing a survey or poll, or providing reviews, testimonials or feedback.",
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                            child: Text(
                              "c. Data that you provide to us, or that we may collect from you, when you report any difficulty you are experiencing in using our Site.",
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "d. Correspondence records if you contact us.",
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "e. General, aggregated, demographic and non-personal data.",
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                            child: Text(
                              "f. If you download or use our mobile application, we may have access to details relating to your location and the location of your mobile device, including your device’s unique identifier.",
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "g. Details of transactions you have made through our Site and details of our processing and delivery of goods you have ordered.",
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                            child: Text(
                              "h. Details about your computer, including, for example, your IP address, operating system and browser type, as well as data relating to your general internet usage (for example, by using technology that stores or accesses data on your device, such as cookies, conversion tracking code, web beacons, etc. (collectively, “Cookies”)).",
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                            child: Text(
                              "i. Your email address, which has been provided to us by third parties who have confirmed to us that they have obtained your consent to share your email address.",
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "j. Any other data we consider necessary to enhance your experience of using the Site.",
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "2. How will we use your data?",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "We may use data in the following circumstances:",
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                            child: Text(
                              "a. To provide you with information, products or services that you request from us or in which we think you may be interested, and where you have consented to being contacted for such purposes.",
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                            child: Text(
                              "b. To provide you with services based on where you are located, such as advertising, search results and other content tailored to you.",
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                            child: Text(
                              "c. To carry out obligations arising from any contracts entered into between you and any other party using our Site, or between you and us.",
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "d. To improve our services and to provide better and more personalized services.",
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "e. To ensure that our site content is presented in the most effective manner for you and the device you are using to access our site.",
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "f. To notify you of changes to our site.",
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "g. For any other reason we deem necessary to enhance your browsing experience on the site.",
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                            child: Text(
                              "h. To administer incentive programs and fulfill your requests for such incentives, and/or to allow you to participate in competitions and notify you if you win.",
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "3. What security measures do we apply?",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                            child: Text(
                              "a. We take the necessary technical, commercial, technical and administrative steps to ensure that data is treated securely and in accordance with this Privacy Policy, in order to protect data from unauthorized access, alteration, disclosure or destruction. For example, we may use encrypted electronic technology to protect data during transmission to our site, in addition to an external electronic firewall, and electronic firewall technology on the computer hosting our site so that we can repel malicious attacks on the network. Only employees, service providers and agents who need to know the data in order to carry out their work will be granted access to it.",
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(40, 8, 8, 10),
                            child: Text(
                              "b. It is important for you to ensure that your password and the device you use to access our site are protected to prevent unauthorized access by third parties. You are solely responsible for keeping your password confidential, for example, by ensuring that you log out after each session.",
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
        floatingActionButton: FloatingActionButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
          backgroundColor: Color(0xff6A66D1).withOpacity(0.6),
          onPressed: _scrollToTop,
          tooltip: 'Move to Top',
          child: Icon(
            Icons.arrow_upward,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
