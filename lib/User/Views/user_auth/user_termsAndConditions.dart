import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;

class UserTermsAndConditions extends StatefulWidget {
  const UserTermsAndConditions({super.key});

  @override
  State<UserTermsAndConditions> createState() => _UserTermsAndConditionsState();
}

class _UserTermsAndConditionsState extends State<UserTermsAndConditions> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  Locale currentLocale = Locale('en', 'US');
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
            preferredSize: const Size.fromHeight(130.0),
            child: Column(
              children: [
                AppBar(
                  scrolledUnderElevation: 0,
                  centerTitle: false,
                  toolbarHeight: 80,
                  automaticallyImplyLeading: false,
                  backgroundColor: const Color(0xff6A66D1),
                  title: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 40),
                      child: Text('Terms and Privacy Policy'.tr(),
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
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: 'Terms & Conditions'.tr()),
                    Tab(text: 'Privacy Policy'.tr()),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            SingleChildScrollView(
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
                  : Column(
                children: [
                  privacyPolicy('1.Introduction',
                      ['These Terms of Use (“Terms”) govern your access to and use of the Naqlee application, available for download on Android and iOS devices via the Google Play Store and Apple App Store. The application, along with all associated pages, content, information, tools, and services (collectively referred to as the "App"), is a service provided by Computer Data Corporation, a company registered under Saudi laws with Commercial Registration Number [2050180086], headquartered at [Outside, King Abdullah Road].',
                        'Before accessing or using the Naqlee app, you must carefully read these Terms, along with our Privacy Policy and any other applicable policies. By registering, accessing, or using the app, you acknowledge that you have read, understood, and agreed to these Terms.',
                        'If you do not agree with these Terms, please do not register, access, or use the Naqlee app.',
                        'These Terms incorporate our Privacy Policy, which outlines how we collect, use, and protect your personal data. By using the app, you consent to our data processing practices and confirm that all information you provide is accurate and up to date.'],
                    boldWords: ['Naqlee','Computer Data Corporation','Commercial Registration Number [2050180086]','[Outside, King Abdullah Road].','Privacy Policy']
                  ),
                  privacyPolicy('2. Definitions', [
                    'For the purposes of these Terms, unless the context requires otherwise, the following definitions shall apply:',
                    '.  "Naqlee" Application: Refers to the Naqlee app available on Android, iOS, and HarmonyOS platforms.',
                    '.  "We", "Us", or "Our": Refers to Computer Data Corporation, the entity that owns and operates the Naqlee application.',
                    '.  "Account": Refers to a registered user account in the Naqlee app, which enables users to access and utilize its services.',
                    '.  "User," "You": Refers to any individual who visits, registers, or uses the Naqlee app, whether as a service provider or a customer.',
                    '.  "Delegate": Refers to any individual or entity (e.g., truck owners) who registers an account in the Naqlee application to sell construction and contracting materials.Referred to in these Terms in plural form as "Delegates.".',
                    '.  "Client": Refers to any individual or entity who registers an account in the Naqlee application to place payment orders through the app.. Referred to in these Terms in plural form as "Clients.".',
                    '.  "Parties": Refers collectively to delegates and clients.',
                    '.  "Materials": Refers to the types of materials used in construction and contracting work.',
                    '.  "Order": Refers to a request made by a Client to a Delegate to purchase a specified quantity of materials.',
                    '.  "Regulations": Refers to the laws and regulations in force in Saudi Arabia.',
                    '.  "Terms and Conditions:" Refers collectively to these Terms of Use and the Privacy Policy, along with any additional policies that may apply.'
                  ], boldWords: [
                    '"Naqlee" Application', '"We", "Us", or "Our"',"Account",'"User," "You"','Computer Data Corporation',
                    '"Delegate"','"Delegates."','"Client"', '"Parties"', '"Materials"', '"Order"', '"Regulations"','"Terms and Conditions:"', 'Privacy Policy','Saudi Arabia','client','delegate','delegates','clients','"Clients."','Naqlee','service provider','customer','.','construction','contracting'
                  ]),
                  privacyPolicy('3. User Account',
                      ['.  Real Identity Registration:',
                        '.  Users must register using their real name and must not use pseudonyms, anonymous names, or misleading information.',
                        '.  If registering on behalf of a business entity, users must provide valid documents proving authorization, such as a legal power of attorney or a certified authorization from the Chamber of Commerce.'
                        '.  The user acknowledges full responsibility for any activities conducted under the registered account.',
                        '.  Accuracy of Information:',
                        '.  Users must provide correct, accurate, and complete information during registration.',
                        '.  Users must promptly update their account details in case of any changes.',
                        '.  Account Security:',
                        '.  Users are responsible for maintaining the confidentiality of their account credentials, including passwords.',
                        '.  Users must not share their account details with third parties.',
                        ".  Any activity conducted through the user's account is the user's responsibility.",
                        '.  Unauthorized Access & Reporting:',
                        '.  Users must take all necessary steps to prevent unauthorized access to their accounts.',
                        '.  Users must immediately report any unauthorized use, hacking attempt, or suspicious activity related to their account.',
                        '.  Verification & Compliance:',
                        '.  Users must cooperate with Naqlee when requested to provide additional verification details.',
                        '.  Providing false or misleading information is strictly prohibited, and users assume full responsibility for any incorrect data submitted.',
                        '.  Account Validity & Suspension:',
                        '.  Naqlee reserves the right to verify registration details and conduct necessary checks.',
                        '.  Once registered, an account remains active for an indefinite period unless suspended or canceled under these terms.'
                      ],
                      boldWords: ['Naqlee','.','Real Identity Registration:','Accuracy of Information:','Account Security:','Unauthorized Access & Reporting:','Verification & Compliance:','Account Validity & Suspension:']
                  ),
                  privacyPolicy('4. Confirmation and Guarantees',
                      ['By registering an account in the Naqlee application, in accordance with the registration provisions outlined above, you agree to the following:',
                        '.  Compliance & Eligibility',
                        '.  You confirm that you meet all eligibility requirements for account registration and comply with the obligations set forth by Naqlee.',
                        '.  Acceptance of Terms',
                        '.  You acknowledge that you have read, understood, and accepted the Terms of Use and Privacy Policy and agree to be bound by their provisions.',
                        '.  Preserving the Integrity of the App',
                        '.  You agree not to engage in any activity that may negatively impact the operation, reputation, or interests of Naqlee.',
                        '.  Lawful Use',
                        '.  You commit to using the Naqlee app only for its intended purpose and in full compliance with its policies, objectives, and applicable laws.',
                        '.  Account Ownership',
                        '.  You must not transfer, sell, or assign your account to another individual or entity without prior written consent from Naqlee.'
                      ],
                      boldWords: ['Naqlee','.','Compliance & Eligibility','Acceptance of Terms','Preserving the Integrity of the App','Lawful Use','Account Ownership']
                  ),
                  privacyPolicy('6. Request Policy',
                      ['The Naqlee application is an electronic platform available for download on Google Play and the Apple App Store, owned and managed by Computer Data Corporation. It facilitates the ordering and delivery of construction materials by connecting customers with registered truck owners (delegates).',
                        '6.1. Order Placement',
                        '.  Customers can place orders for specific types and quantities of construction materials and specify an exact delivery location.',
                        '.  Once an order is placed, it becomes visible to delegates (truck owners) registered on the application.',
                        '6.2. Pricing & Order Agreement',
                        '.  Each delegate sets the price based on the type, quantity, location, and distance of the order.'
                        '.  The customer selects the best-suited offer and communicates with the delegate via the application to finalize order details (material type, quantity, pickup location, and payment method).',
                        '6.3. Customer Responsibilities',
                        '.  Customers must accurately provide order details, including the delivery address and the authorized recipient.',
                        '.  Customers must complete payment through one of the available payment methods in the application.',
                        '6.4. Delegate Responsibilities',
                        '.  Once an order is accepted, both parties enter into a direct and legally binding agreement to ensure delivery.',
                        '.  The delegate must notify the Naqlee administration if, for any reason, they are unable to fulfill the order.',
                        '.  The delegate is fully responsible for any errors or issues arising during the delivery process.',
                        '6.5. Communication & Compliance',
                        '.  All official communication between customers and delegates must take place within the application’s chat system.',
                        '.  Conducting transactions outside the app is strictly prohibited. Violating this policy may result in temporary or permanent suspension of the user’s account.',
                        '6.6. Role of Naqlee',
                        '.  Naqlee solely acts as an intermediary connecting delegates and customers in exchange for a commission per order.',
                        '.  Naqlee does not sell, request, or deliver construction materials—it only facilitates the connection between both parties.',
                        '6.7. Legal Acknowledgments',
                        '.  The customer acknowledges that their contractual relationship exists directly with the delegate, and Naqlee is not responsible for pricing, delivery, or the actions of truck owners.',
                        '.  The delegate acknowledges that Naqlee’s role ends once the order is accepted, and all legal obligations related to the transaction are between the customer and the delegate.',
                      ],
                    boldWords: ['.','Naqlee','6.1. Order Placement','6.2. Pricing & Order Agreement','6.3. Customer Responsibilities','6.4. Delegate Responsibilities','6.5. Communication & Compliance','6.6. Role of Naqlee','6.7. Legal Acknowledgments']
                  ),
                  privacyPolicy('7. Payment Policy',
                  ['The Naqlee application offers the following payment options:',
                    '.  Electronic Payment via SADAD and Apple Pay',
                    '.  Cash payment upon delivery',
                    '.  Users must ensure that payment details are entered correctly.',
                    '.  Payment is due immediately upon completing the transaction.',
                    '.  A payment confirmation notification will be sent to the registered email within 24 hours.',
                    '.  If the payment is declined, users will be notified of the issue and can choose an alternative payment method.',
                    '7.1. User Responsibility',
                    '.  Users agree to bear all applicable payment fees.',
                    '.  Computer Data Corporation reserves the right to modify the Payment Policy at any time, including adding or removing payment methods.',
                  ],
                    boldWords: ['Naqlee','7. Payment Policy','7.1. User Responsibility']
                  ),
                  privacyPolicy('8. Fee and Commission Policy',
                      ['8.1. Account Registration',
                        '.  Registering an account in the Transfer App is free of charge.',
                        '.  The app reserves the right to introduce registration fees in the future if deemed necessary.',
                        '8.2. Commission Fees',
                        '.  The Naqlee application charges a 5% commission on the total order price for each transaction completed through the app.',
                        '.  The client acknowledges and agrees to pay this commission.',
                        '8.3. Non-Refundable Commission',
                        '.  Once an agreement is finalized between the client and delegate, the commission becomes non-refundable.',
                        '.  In the event of any disputes, the involved parties shall bear the consequences, and the Naqlee app will not be liable for refunds.',
                      ],
                    boldWords: ['.','8.1. Account Registration','8.2. Commission Fees','8.3. Non-Refundable Commission']
                  ),
                  privacyPolicy('9. Licenses and Restrictions on Use',
                      ['9.1. License Grant',
                        'Under these terms, Computer Data Corporation grants you a limited, non-exclusive, non-transferable, and non-sublicensable personal license to:',
                        '.  Download and install a copy of the Naqlee app on a device you own or control.',
                        '.  Access the app’s content, information, and materials solely for personal use, in compliance with these Terms.',
                        'This license does not grant you any ownership rights in the application. Your usage of the app does not create any partnership, joint venture, or employment relationship between you and us.',
                        '9.2. Prohibited Uses',
                        'The following actions are strictly prohibited when using the Naqlee App:',
                        '9.2.1. Unlawful Use',
                        '.  Using the app to violate any applicable laws or cause damage or financial losses to us or others.',
                        '9.2.2. Unauthorized Commercial Exploitation',
                        '.  Licensing, renting, selling, transferring, distributing, hosting, or commercially exploiting any part of the app or service.',
                        '9.2.3. Security Violations',
                        '.  Testing, probing, hacking, or attempting to bypass the security systems of the app.',
                        '.  Attempting to disable, interfere with, or circumvent any security-related features.',
                        '9.2.4. Reverse Engineering',
                        '.  Decoding, decompiling, encrypting, or reverse engineering any software used in the application.',
                        '9.2.5. Unauthorized Copying and Resale',
                        '.  Reproducing, copying, selling, or reselling any part of the app for commercial gain without explicit written consent.',
                        '9.2.6. Identity Misrepresentation',
                        '.  Impersonating another user, entity, employee, or representative of the Naqlee App.',
                        '9.2.7. Unauthorized Use of Branding',
                        '.  Using any hidden text, meta-tags, or branding elements related to Naqlee without permission.',
                        '9.2.8. Unsolicited Communications & Spam',
                        '.  Publishing or sending unsolicited content, including:',
                        '.  Advertising or promotional materials.',
                        '.  Spam, chain messages, or pyramid schemes.',
                        '9.2.9. Malware & Harmful Code',
                        '.  Uploading or sending any material containing viruses, Trojans, worms, spyware, or malicious code intended to harm systems.',
                        '9.2.10. Intellectual Property Violations',
                        '.  Removing, modifying, or destroying any copyrights, trademarks, or proprietary rights in the Naqlee App.',
                        '.  Infringing upon intellectual property rights, including copyrights, trademarks, patents, or database rights.',
                        '9.3. Termination of License',
                        '.  The license granted under these Terms automatically expires if you fail to comply with any of the Terms of Use.',
                        '.  In case of a violation, we reserve the right to revoke access, suspend your account, and take legal action if necessary.',
                      ],
                      boldWords: ['.','Naqlee','9.1. License Grant','9.2. Prohibited Uses','9.2.1. Unlawful Use','9.2.2. Unauthorized Commercial Exploitation','9.2.3. Security Violations','9.2.4. Reverse Engineering','9.2.5. Unauthorized Copying and Resale','9.2.6. Identity Misrepresentation','9.2.7. Unauthorized Use of Branding','9.2.8. Unsolicited Communications & Spam','9.2.9. Malware & Harmful Code','9.2.10. Intellectual Property Violations','9.3. Termination of License']
                  ),
                  privacyPolicy('10. Disclaimer',
                  ['10.1. General Disclaimer',
                    'The Naqlee App, its content, services, and related information are provided "as is" and "as available," without any warranties of any kind, whether express or implied. The Naqlee App administration reserves the right to modify or update any content, material, or service on the app at any time.',
                    '10.2. No Warranties',
                    'Computer Data Corporation disclaims all warranties of any kind (explicit, implied, or legal) related to this application, including but not limited to:',
                    '.  Marketability',
                    '.  Fitness for a particular purpose',
                    '.  Suitability for user needs',
                    '10.3. Service Availability',
                    'We do not guarantee that the Naqlee App will be available continuously or without interruptions. While we strive for round-the-clock availability, the app may be temporarily unavailable due to',
                    '.  Routine maintenance and updates',
                    '.  Technical issues or unexpected failures',
                    '.  System upgrades and enhancements',
                    '10.4. Limitation of Liability',
                    'The Naqlee App is not responsible for any direct, indirect, consequential, or incidental damages, including but not limited to:',
                    '10.4.1. User or Delegate Errors',
                    '.  Errors in selecting the type or quantity of requested services.',
                    '.  Delegate errors during the delivery process.',
                    '10.4.2. Service Incompatibility',
                    '.  Issues where the requested service does not match the actual requirement or purpose.',
                    '10.4.3. Delayed Deliveries',
                    '.  Delays in order processing and delivery by the delegate.',
                    '10.4.4. Financial and Transactional Risks',
                    '.  All financial transactions and obligations between parties.',
                    '10.4.5. Business Losses',
                    '.  Loss of profits, sales, revenue, or business opportunities.',
                    '10.4.6. Security & Data Privacy Issues',
                    '.  Failure by users to maintain the confidentiality of their account information.',
                    '10.4.7. External Factors',
                    '.  Issues related to equipment, devices, networks, or communication failures affecting the app.',
                    '10.4.8. External Links',
                    '.  Content, reliability, or safety of third-party websites accessed through the app.',
                    '10.5. Advertiser Responsibility',
                    'The Naqlee App does not guarantee the accuracy, completeness, or reliability of ads, content, images, or prices. Advertisers are solely responsible for reviewing and ensuring the accuracy of their content.',
                    '10.6. Security & Data Protection',
                    'The Naqlee App is designed with state-of-the-art encryption to ensure data security and confidentiality. However, no system is 100% secure. We are not liable for:',
                    '.  Viruses, malware, or data corruption affecting your mobile device.',
                    '.  Any unauthorized access or data breaches beyond our control.',
                    '10.7. User Responsibility',
                    'By using the Naqlee App, you confirm that:',
                    '.  All information provided is accurate and truthful.',
                    '.  Each party is responsible for the data they send or receive through the app.',
                    '10.8. Role of Naqlee App',
                    'The Naqlee app serves only as an intermediary between parties. Once a request is accepted and completed, all related obligations and responsibilities are transferred to the involved parties.',
                    '10.9. Modification of Services',
                    'We reserve the right to:',
                    '.  Modify, suspend, or discontinue services at any time without prior notice.',
                    '.  Restrict or terminate user access in case of policy violations or misuse.',
                    '10.10. Account Suspension & Termination',
                    'Without prejudice to any other rights, the Naqlee App Administration has the right to:',
                    '.  Suspend or delete user accounts at any time without prior notice.',
                    '.  Restrict access to the app for any reason, without limitation.',
                  ],
                  boldWords: ['10.1. General Disclaimer','10.2. No Warranties','10.3. Service Availability','10.4. Limitation of Liability','10.4.1. User or Delegate Errors','10.4.2. Service Incompatibility','10.4.3. Delayed Deliveries','10.4.4. Financial and Transactional Risks','10.4.5. Business Losses','10.4.6. Security & Data Privacy Issues','10.4.7. External Factors','10.4.8. External Links','10.5. Advertiser Responsibility','10.6. Security & Data Protection','10.7. User Responsibility','10.8. Role of Naqlee App','10.9. Modification of Services','10.10. Account Suspension & Termination','Naqlee'
                  ]
                  ),
                  privacyPolicy('11. Intellectual Property Rights and Trademark',
                  ['11.1. Ownership and Protection',
                    'Computer Data Corporation reserves all rights, ownership, and interests in the Naqlee App, including but not limited to:',
                     '.  Concepts and ideas expressed within the app.',
                     '.  Hardware, software, and technological components used to operate the app.',
                     '.  Copyrights, patents, trademarks, and trade secrets.',
                     '.  Visual elements such as text, graphics, fonts, images, and designs.',
                     '.  Multimedia content, including audio, video, and digital materials.',
                     '.  Data sets, programming rights, and software code.',
                     'All these elements are protected under intellectual property and trademark laws.',
                     '11.2. Trademarks and Designs',
                     '.  Logos, words, headers, button icons, and service names associated with the Naqlee App are trademarks and designs owned by Computer Data Corporation.',
                     '.  You may not reproduce, imitate, or use them for promotional or commercial purposes without explicit written permission.',
                     '.  Any third-party trademarks, service marks, or brand names mentioned in the app remain the property of their respective owners.',
                     '11.3. Unauthorized Use',
                     'Any unauthorized use, copying, imitation, or modification of the Naqlee App trademark or branding is strictly prohibited and constitutes a violation of trademark protection laws.',
                     '11.4. No License or Rights Granted',
                     'These Terms & Conditions, along with any content in the app, do not grant any license or right to use the Naqlee App trademarks without prior written approval from the app administration.',
                  ],
                  boldWords: ['11.1. Ownership and Protection','11.2. Trademarks and Designs','11.3. Unauthorized Use','11.4. No License or Rights Granted','.','Naqlee']
                  ),
                  privacyPolicy('12. Compensation',
                  ["12.1. User's Obligation to Indemnify",
                    'You agree to indemnify and hold harmless Computer Data Corporation, its officers, employees, and agents from any losses, damages, claims, fines, costs, obligations, or expenses (including legal and attorney fees) arising from:',
                    '.  Any claims related to your use of the Naqlee App.',
                    '.  Abuse or illegal use of the Naqlee app in any form.',
                    '.  Providing false, misleading, or inaccurate information to us.',
                    '.  App failures, suspensions, or outdated versions affecting its functionality.',
                    '.  Violation or non-compliance with the Terms of Use or Privacy Policy of the Naqlee App.',
                    '.  Violation of any applicable laws, including data protection laws.',
                    '.  Infringement of intellectual property rights (copyright, trademarks, or other rights).',
                    '12.2. Exclusion of Liability',
                    'The Naqlee App disclaims all warranties, terms, and conditions regarding:',
                    '.  Financial losses, defamation, or damages caused by misuse.',
                    '.  Any claims arising from the use of the app, including but not limited to technical issues, interruptions, or failures.',
                    '12.3. Limitation of Liability',
                    'Neither Naqlee App, its management, nor its employees shall be legally responsible to you or any third party for:',
                    '.  Any direct or indirect losses, including financial or reputational damage.',
                    '.  Any costs incurred due to the implementation of these terms or the provision of the service.',
                    '12.4. Protection of the Naqlee App',
                    'As a user, you agree to protect, defend, and compensate the Naqlee App and its affiliates against any claims, liabilities, or damages resulting from:',
                    '.  Your actions or negligence while using the app.',
                    '.  Actions taken by your representatives or agents related to the app.',
                    '12.5. Indemnification for Unauthorized Use',
                    'You agree to compensate the Naqlee App for any losses or damages caused by any illegal or unauthorized use of the app.',
                  ],
                  boldWords: ['Naqlee',"12.1. User's Obligation to Indemnify",'12.2. Exclusion of Liability','12.3. Limitation of Liability','12.4. Protection of the Naqlee App','12.5. Indemnification for Unauthorized Use','.']
                  ),
                  privacyPolicy('13. External Links',
                  ['13.1. Third-Party Links',
                    'The Naqlee App may contain links to websites operated by third parties that are not affiliated with Computer Data Corporation. We do not endorse these links and are not responsible for the content, information, or materials available on these external sites. If you choose to access these websites, you do so at your own risk.',
                    '13.2. No Endorsement or Warranty',
                    'The presence of external links on the Naqlee App does not imply endorsement or authorization of their use. The Naqlee App makes no guarantees, representations, or warranties regarding the security, reliability, or accuracy of these external links.',
                    '13.3. User Responsibility for Third-Party Websites',
                    'Before using any third-party websites or providing them with your personal data, please ensure you have reviewed their privacy policies and terms of service.',
                  ],
                  boldWords: ['Naqlee','13.1. Third-Party Links','13.2. No Endorsement or Warranty','13.3. User Responsibility for Third-Party Websites']),
                  privacyPolicy('14. Electronic Communications',
                  ['14.1. Official Communication',
                    'We may communicate with the user via the email address registered in the Naqlee app regarding updates to these terms and privacy policy, administrative messages, technical notices, and security alerts. The user agrees that all electronic communications meet legal requirements as if they were provided in written form.',
                    '14.2. Promotional Communication',
                    'We may also communicate with the user for promotional purposes regarding new features, updates, or activities added to the Naqlee app. If the user wishes to opt out of receiving such communications, they can unsubscribe at any time by clicking the "unsubscribe" link at the bottom of the email.',
                  ],
                  boldWords: ['Naqlee','14.1. Official Communication','14.2. Promotional Communication']
                  ),
                  privacyPolicy('15. Duration and Termination',
                  ['15.1. Duration',
                    'These terms remain in effect for the duration of your account registration and use of the Naqlee app, unless terminated by either party.',
                    '15.2. Termination by Naqlee App',
                    'The Naqlee App administration reserves the right to immediately terminate these terms if any of the following conditions are met:',
                    '.  15.2.1. Violation of these Terms, Privacy Policy, or rules for using the Naqlee App.',
                    '.  15.2.2. Proven misuse of the Naqlee App or any use that creates legal issues for us.',
                    '15.3. Termination by the User',
                    'The user may terminate these terms at any time by uninstalling the Naqlee app from their device. Upon termination, all licenses and permissions granted under these terms will immediately cease.',
                  ],
                  boldWords: ['Naqlee','.','15.1. Duration','15.2. Termination by Naqlee App','15.3. Termination by the User']
                  ),
                  privacyPolicy('16. Amendments to the Terms',
                  ['16.1. Right to Modify',
                    'The Computer Data Corporation reserves the right to modify, update, supplement, replace, or remove any provision of these Terms, and the User shall be bound by any amendments deemed necessary.',
                    '16.2. Effective Date of Amendments',
                    'All modifications take effect immediately upon being published on the Naqlee App and apply to all subsequent use.',
                    '16.3. Service Changes',
                    'The Computer Data Corporation reserves the right to change, suspend, or discontinue the services offered through the Naqlee App. It may also modify or enhance the application by adding new features to improve efficiency. The user must comply with any directives or instructions issued by the Naqlee app regarding such modifications.',
                  ],
                  boldWords: ['Naqlee','16.1. Right to Modify','16.2. Effective Date of Amendments','16.3. Service Changes']
                  ),
                  privacyPolicy('17. Jurisdiction',
                  ['17.1. Governing Law',
                    'These terms shall be governed by and interpreted in accordance with the laws of the Kingdom of Saudi Arabia.',
                    '17.2. Severability',
                    'If any provision of these Terms is found to be unenforceable or invalid by a court or government authority in the Kingdom of Saudi Arabia, that provision shall be deemed severable and removed from these Terms, while the remaining provisions shall continue to be in full force and effect.',
                  ],
                  boldWords: ['Naqlee','17.1. Governing Law','17.2. Severability']
                  ),
                  privacyPolicy('18. Transfer of Rights and Obligations',
                  ['18.1. Transfer by Computer Data Corporation',
                    'The Computer Data Corporation reserves the right to assign, transfer, or delegate any or all of its rights and obligations under these Terms to a third party without requiring prior approval from the User, provided that the third party agrees to be bound by these Terms.',
                    '18.2. Restrictions on User Assignment',
                    'The user is strictly prohibited from assigning, transferring, or delegating any of their rights or obligations under these terms to any third party without the Computer Data Corporation’s express written consent. Additionally, the user may not authorize any third party to manage their account unless explicitly permitted.',
                  ],
                  boldWords: ['18.1. Transfer by Computer Data Corporation','18.2. Restrictions on User Assignment']
                  ),
                  privacyPolicy('19. Force Majeure',
                  ['The Computer Data Corporation shall not be held liable for any delay or failure to perform its obligations under these Terms if such delay or failure results from force majeure or extraordinary circumstances beyond its reasonable control. This includes, but is not limited to, natural disasters, acts of war, government actions, power outages, cyberattacks, or any unforeseen event that disrupts the normal functioning of the application.']),
                  privacyPolicy('20. Relationship of the Parties',
                  ['Nothing in these terms shall be construed as creating a partnership, joint venture, agency, or employment relationship between Computer Data Corporation and any user (whether a delegate, customer, or third party). Neither party shall have the authority to bind, represent, or act on behalf of the other in any manner.']),
                  privacyPolicy('21. Conflict Resolution',
                  ['In the event of any conflict between these terms and any previous versions, the most recent version shall prevail and take precedence.']),
                  privacyPolicy('22. Notification',
                  ["The Transfer App may send notifications to the user through in-app notifications or via the registered email associated with the user's account."]),
                  privacyPolicy('23. Language',
                  ['These terms are written in Arabic, and if they are translated into another language, the Arabic text shall prevail in case of any discrepancies or conflicts.']),
                  privacyPolicy('24. Full Agreement',
                  ['These Terms and the Privacy Policy (including any amended versions) constitute the entire agreement between you (the delegate and the customer) and the Computer Data Corporation. They supersede any prior agreements, communications, or previous versions of these terms.']),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Contact us.',
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'If you have any questions about these terms or practices related to the “Tille” app, please feel free to contact us at: E-mail: © Copyright @raml.'
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Copyright © "Tali" 2024',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'All rights reserved to Computer Data Foundation.',
                      ),
                    ),
                  ),
                ],
              )
            ),
            SingleChildScrollView(
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
                  ],
                 ),
                )
                : Column(
                children: [
                  privacyPolicy('1.Introduction',
                      ['1.1 This Privacy Policy (“Policy”) constitutes a legally binding and enforceable contract between you (“User”) and Computer Data Corporation (the owner, operator, controller, and entity responsible for the privacy policy of the “Naqlee” App). Please read it carefully before using the app.',
                      '1.2. We respect the privacy of all users and are committed to protecting their personal data. This policy has been developed to help you understand how Computer Data Corporation collects, uses, and shares personal data, as well as how we secure and handle this data when you visit and use the "Naqlee" app.']
                  ),
                  privacyPolicy('2. Approval of Policy', [
                    '2.1 By accessing or using the “Naqlee” app, you acknowledge that you have read this Privacy Policy and the Terms of Use (“Terms and Conditions”) and expressly agree to be bound by all the terms stated therein.',
                    '2.2 By using the “Naqlee” app or placing orders through it, you expressly consent to the collection, use, processing, and storage of your personal data in accordance with this policy. You also allow us to communicate with you regarding services and products that may be of interest to you and agree to any future changes to the Privacy Policy.',
                    '2.3 If you do NOT agree to the practices described in this policy, you may not use this app.',
                  ]),
                  privacyPolicy('3. Scope of Policy', [
                    '3.1 This policy applies to anyone who visits, browses, or uses the Naqlee mobile & web application, including all information, data, services, tools, and other features provided through the app.',
                    '3.2 This policy does not apply to any third-party websites, applications, or services linked to the Naqlee app. It also does not cover information collected or provided through platforms owned by other companies or institutions.',
                  ]),
                  privacyPolicy('4. General Principles of Privacy', [
                    'The Computer Data Foundation has established key principles regarding users’ personal data:',
                    '4.1 Publish and update this policy as needed to clarify data practices related to the use of the “Naqlee” app.',
                    '4.2 Collect and use personal data only for the purposes outlined in this policy.',
                    '4.3 Process personal data in accordance with the purposes for which it was collected, used, and shared.',
                    '4.4 Take reasonable steps to ensure that personal data is reliable, accurate, complete, and up to date.',
                    '4.5 Implement appropriate measures to provide adequate protection for data shared with third parties.',
                  ],
                    boldWords: ['Computer Data Foundation','Naqlee','4.1','4.2','4.3','4.4','4.5'],
                  ),
                  privacyPolicy('5. Methods of Data Collection', [
                    'The Naqlee app collects personal data from users through various methods, as outlined below:',
                  ],
                    boldWords: ['Naqlee'],
                  ),
                  privacyPolicy('5.1 Direct Interactions', [
                    '5.1.1 Account Data: When registering an account on the Naqlee app, users provide specific details such as their name, email, mobile number, and any additional information requested by the app administration.',
                    '5.1.2 Contact Details: When contacting us through the app or responding to email messages, we may collect data such as your name, email, message content, and subject.',
                    '5.1.3 Order Data: When placing an order through the Naqlee app, we collect information including the recipient’s name, product type and quantity, total order amount, phone number, shipping address, invoices, and any other necessary details required by applicable regulations.',
                    '5.1.4 Payment Data: When making a payment, users must complete transactions using one of the available payment methods in the app. Payment details are securely transmitted to contracted payment service providers for processing.',
                    '5.1.5 Subscription Data: When subscribing to newsletters or filling out any forms provided by the app.',
                    '5.1.6 User-Generated Content: When submitting comments, feedback, or reviews within the app.',
                  ],
                    boldWords: ['Naqlee','5.1.1 Account Data:','5.1.2 Contact Details:','5.1.3 Order Data:','5.1.4 Payment Data:','5.1.5 Subscription Data:','5.1.6 User-Generated Content:'],
                  ),
                  privacyPolicy('5.2 Automated Interactions', [
                    '5.2.1 Technical Data: We may collect technical details such as your IP address, browser type, referral/exit pages, ISP, device identifiers, advertising ID, operating system, installed plugins, access date and time, number of clicks, usage information, and data on connected devices.',
                    '5.2.2 Log Data: This includes records of device activity, internal analytics tools, products viewed or searched for, page response times, duration of visits, interaction details, geolocation data, and any phone number used to contact customer support.',
                    '5.2.3 Approximate Location Data: Such as state, city, and geographic coordinates, which may be determined based on your IP address or device location settings.',
                    '5.2.4 Tracking Technologies: We use cookies, tracking pixels, and web beacons to collect and store relevant personal data.',
                  ],
                    boldWords: ['5.2.1 Technical Data:','5.2.2 Log Data:','5.2.3 Approximate Location Data:','5.2.4 Tracking Technologies:'],
                  ),
                  privacyPolicy('5.3 Third-Party Data Sources', [
                    '5.3.1 Data from Partners: This includes information shared by marketing and advertising partners, as well as other affiliated parties.',
                    '5.3.2 Social Media Data: We may collect relevant information from social media platforms such as Facebook, Twitter, and others.',
                  ],
                    boldWords: ['5.3.1 Data from Partners:','5.3.2 Social Media Data:']
                  ),
                  privacyPolicy('6. Purposes of Data Use', [
                    'The Naqlee app collects and processes user data for the following purposes:',
                    '6.1 Assisting users in creating accounts, verifying identity, and securely logging into their accounts.',
                    '6.2 Enhancing our business operations, including improving app content, functionality, and customer service.',
                    '6.3 Providing technical support and responding to user inquiries, questions, and emails.',
                    '6.4 Sending administrative notifications related to services, including updates on the Privacy Policy, account confirmations, security alerts, and other relevant information.',
                    '6.5 Offering personalized suggestions and recommendations based on user activity within the app.',
                    '6.6 Improving services by customizing the user experience.',
                    '6.7 Preventing fraudulent, prohibited, or illegal activities, ensuring compliance with applicable regulations, and enforcing our Terms of Service.',
                    '6.8 Conducting market research, surveys, and analytical studies for statistical and promotional purposes.',
                  ],
                      boldWords: ['Naqlee','6.1','6.2','6.3','6.4','6.5','6.6','6.7','6.8']
                  ),
                  privacyPolicy('7. Data Sharing', [
                    '7.1 We share the personal data we collect in accordance with this Policy with our affiliates and third parties to fulfill the purposes outlined in Section 6. We may share data in the following cases:',
                    '7.1.1 With Your Consent: We may share your data if you provide explicit consent for a specific purpose.',
                    '7.1.2 Legitimate Interests: We may share data when necessary to pursue our legitimate business interests.',
                    '7.1.3 Contract Performance: Sharing your personal data may be necessary to fulfill our contractual obligations to you.',
                    '7.1.4 Legal Obligations: We may disclose your data if required by a court order or to comply with applicable laws and regulations.',
                    '7.1.5 Vital Interests: We may share data to investigate, prevent, or address potential policy violations, suspected fraud, security threats, illegal activities, or as evidence in legal proceedings.',
                    '7.1.6 Truck Owners: When you place an order for transportation services through the Naqlee app, we share necessary user data with drivers to facilitate order fulfillment and delivery.',
                    '7.1.7 Payment Processing: To complete payments within the Naqlee app, users may need to provide specific payment-related data. We may share this data with payment processors for transaction processing, including fraud detection and security measures.',
                    '7.1.8 Marketing & Promotions: We may share data with third-party partners who assist us in marketing, service promotion, and improving user experience.',
                    '7.1.9 Business Transfers: In the event of a merger, acquisition, restructuring, asset sale, joint venture, or similar transaction, we may transfer personal data to the new entity, which will use the data in accordance with this Policy.',
                  ],
                      boldWords: ['Section 6','7.1','7.1.1 With Your Consent:','7.1.2 Legitimate Interests:','7.1.3 Contract Performance:','7.1.4 Legal Obligations:','7.1.5 Vital Interests:','7.1.6 Truck Owners:','7.1.7 Payment Processing:','7.1.8 Marketing & Promotions:','7.1.9 Business Transfers:']
                  ),
                  privacyPolicy('7.2 Third-Party Processing:',[
                    'By using our services, you authorize us to allow our employees and business partners to process your personal data as necessary to provide services. Please note: Third parties’ use of your data will be governed by their respective privacy policies, and we recommend reviewing them carefully.'
                  ],
                      boldWords: ['Please note:']
                  ),
                  privacyPolicy('8. Data Storage and Retention', [
                    '8.1 Retention Period: The Naqlee app stores users’ personal data for as long as necessary to fulfill the purposes outlined in Section 6. In some cases, data may be retained for longer periods to comply with legal obligations, enforce our policies, or protect against potential claims.',
                    '8.2 Account Data Retention: We retain data associated with user accounts in electronic records for as long as the account remains active. The retention period is determined based on:',
                    '.  The duration of account activity.',
                    '.  The nature and sensitivity of the personal data collected.',
                    '.  The length of service provision.',
                    '.  Legal obligations, such as compliance with government orders, investigations, litigation, or potential legal claims.',
                    '8.3 Internal Use and Security: We may retain personal data for:',
                    '.  Internal analysis and research purposes.',
                    '.  Enhancing security and fraud prevention.',
                    '.  Improving app functionality and user experience.',
                    '.  Legal, marketing, and accounting requirements.',
                    '.  Enforcing our legal terms and policies.',
                    'Once data is no longer needed, it will be securely deleted or anonymized in accordance with applicable regulations.',
                  ],
                      boldWords: ['8.1 Retention Period:','Naqlee','Section 6','legal obligations','8.2 Account Data Retention:','for as long as the account remains active','.','8.3 Internal Use and Security:']
                  ),
                  privacyPolicy('9. Data Protection & Security Measures', [
                    '9.1 Security Measures: We implement appropriate security measures to protect users’ personal data on the Naqlee app from loss, damage, alteration, unauthorized access, or misuse. These measures include:',
                    '.  Firewalls to prevent unauthorized network access.',
                    '.  Data encryption to protect sensitive information.',
                    '.  Physical access controls for our data centers.',
                    '.  Strict access controls to ensure only authorized personnel can access data.',
                    '.  Despite these efforts, users should be aware that no online system is 100% secure. While we maintain high-security standards, users must also follow their own security best practices.',
                    '9.2 User Responsibility: To help maintain security, users should:',
                    '.  Keep their account credentials confidential.',
                    '.  Avoid sharing passwords or login details with others.',
                    '.  Regularly update passwords and enable additional security features where available.',
                    '9.3 Data Confidentiality & Usage: We do not rent, sell, or misuse your personal data in any personally identifiable way.',
                    '.  We do not allow third parties to use your data for direct or indirect marketing without your explicit consent.',
                    '.  Personal data is only used for the purposes outlined in this policy and retained only as long as necessary to provide services.',
                  ],
                      boldWords: ['.','9.1 Security Measures:','Naqlee','loss, damage, alteration, unauthorized access, or misuse','Firewalls','Data encryption','Physical access controls','Strict access controls','no online system is 100% secure','9.2 User Responsibility:',
                      'account credentials confidential','passwords','9.3 Data Confidentiality & Usage:','do not rent, sell, or misuse','direct or indirect marketing','purposes outlined in this policy']
                  ),
                  privacyPolicy('10. Protection of Account Access Data', [
                    '.  User Responsibility: The security of account login data (e.g., username, password, or any authentication details) is the sole responsibility of the user.',
                    '.  Unauthorized Access: If another person obtains the user’s login credentials by any means and accesses the app or conducts transactions, the user is fully responsible for any resulting actions.',
                    '.  App Disclaimer: The Naqlee app bears no responsibility for unauthorized activities performed using compromised login credentials.',
                  ],
                      boldWords: ['User Responsibility:','Unauthorized Access:','App Disclaimer:','account login data','the user is fully responsible','Naqlee','bears no responsibility']
                  ),
                  privacyPolicy('11. Changes in Account Data', [
                    'Ensuring the accuracy and timeliness of your personal data is essential. Please inform us promptly of any updates or modifications to your personal information during your interactions with us.',
                  ],
                      boldWords: ['timeliness']
                  ),
                  privacyPolicy('12. External Links', [
                    '12.1 The Naqlee application may contain links directing users or visitors to external websites, applications, or platforms that may collect and process personal information differently from Naqlee.',
                    '12.2 Naqlee does not control or oversee the privacy practices of third-party sites and is not legally responsible for the content posted on those platforms or their respective privacy policies.',
                    '12.3 Users are encouraged to review the Privacy Policy and Terms of Use of any third-party sites they visit through external links. By accessing such links, users acknowledge that Naqlee is not liable for the collection, use, or disclosure of their data by these third parties.',
                  ],
                      boldWords: ['Naqlee','Privacy Policy','Terms of Use']
                  ),
                  privacyPolicy('13. User Responsibilities', [
                    '13.1 The user is responsible for providing complete, accurate, and up-to-date information and for maintaining the confidentiality of their account details.',
                    '13.2 The user acknowledges that the Naqlee application only controls the data collected through the app and has no authority over any information provided outside the application.',
                    '13.3 Naqlee is not liable for any privacy breaches resulting from the user’s failure to protect their personal data.',
                    '13.4 The user plays a crucial role in safeguarding their personal information by:',
                    '.  13.4.1.Reviewing, managing, and updating their personal data through their account settings within the app.',
                    '.  13.4.2.Keeping account credentials confidential and not sharing login details with others.',
                    '.  13.4.3.Logging out after each session, especially when using public or shared devices.',
                  ],
                      boldWords: ['Naqlee','13.4.1.','13.4.2.','13.4.3.','.']
                  ),
                  privacyPolicy('14. Cookies Policy', [
                    '14.1 The Naqlee application uses cookies for essential functions such as app navigation, delivering personalized advertisements, enhancing the shopping experience, and other purposes. Users can manage their cookie preferences through the following options:',
                    '.  14.1.1. Configure the browser to notify them when cookies are received.',
                    '.  14.1.2. Adjust browser settings to accept or reject cookies.',
                    '.  14.1.3. Use private or incognito browsing mode.',
                    '.  14.1.4. Clear cookies after visiting the application.',
                    '14.2 Disabling cookies may affect the functionality of certain app features, causing some pages to display incorrectly or not load properly.',
                  ],
                      boldWords: ['Naqlee','14.1.1.','14.1.2.','14.1.3.','14.1.4.','.']
                  ),
                privacyPolicy('15. Amendments to the Privacy Policy', [
                  '15.1 The Naqlee application reserves the right to modify this Privacy Policy at any time to reflect current practices, comply with legal requirements, or enhance user privacy protections. Any amendments or clarifications will take effect immediately upon publication in the application.',
                  '15.2 If significant changes are made to this policy, we will notify users where possible. Updates will be posted on this page, and the effective date will be revised accordingly to ensure transparency regarding the collection, use, and disclosure of information.',
                  '15.3 Users are encouraged to review this policy regularly to stay informed about any modifications. Failure to review the updated policy before using the application does not exempt users from compliance. Continued use of the Naqlee application constitutes acceptance of all terms and amendments outlined in this policy.',
                ],
                  boldWords: ['Naqlee']
                ),
                privacyPolicy('16. Approval of the Privacy Policy', [
                  '16.1 By using the Naqlee application, the user acknowledges that they have read and understood this Privacy Policy and agree to comply with all its terms and conditions.',
                  '16.2 The user further agrees that continued use of the Naqlee application or its services constitutes explicit acceptance of this policy and the terms governing the use of the application.',
                ],
                    boldWords: ['Naqlee']
                ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Questions and comments',
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'If you have any questions or concerns about this Privacy Policy, please contact us at:',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'E-mail: Sales@naqlee.com',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Copyright © 2025',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'All rights reserved to Computer Data Foundation.',
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
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

  Widget privacyPolicy(String heading, List<String> contents, {List<String> boldWords = const []}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              heading,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
        ),
        ...contents.map((content) => Padding(
          padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
          child: _highlightText(content, boldWords),
        )),
      ],
    );
  }

  Widget _highlightText(String text, List<String> boldWords) {
    List<TextSpan> spans = [];
    String remainingText = text;

    List<String> sortedBoldWords = List.from(boldWords);
    sortedBoldWords.sort((a, b) => b.length.compareTo(a.length));

    while (remainingText.isNotEmpty) {
      int firstMatchIndex = remainingText.length;
      String? matchedWord;

      for (String word in sortedBoldWords) {
        word = word.trim();
        int matchIndex = remainingText.indexOf(word);
        if (matchIndex != -1 && matchIndex < firstMatchIndex) {
          firstMatchIndex = matchIndex;
          matchedWord = word;
        }
      }

      // 🔴 Prevent infinite loop by breaking if no match is found
      if (matchedWord == null) {
        spans.add(TextSpan(text: remainingText));
        break;
      }

      // 🔴 Append normal text before the match
      if (firstMatchIndex > 0) {
        spans.add(TextSpan(text: remainingText.substring(0, firstMatchIndex)));
      }

      // ✅ Append matched word in bold
      spans.add(TextSpan(text: matchedWord, style: TextStyle(fontWeight: FontWeight.bold)));

      // 🔴 Reduce remaining text correctly to avoid infinite loops
      remainingText = remainingText.substring(firstMatchIndex + matchedWord.length);

      // ✅ Prevent infinite loop by ensuring remainingText is reducing
      if (remainingText == text) {
        break;
      }
    }

    return Text.rich(TextSpan(children: spans));
  }

}
