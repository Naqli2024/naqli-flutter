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
                    icon: Icon(Icons.language, color: Color(0xff7f6bf6)),
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
                          "المقدمة.1",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'تحكم شروط الاستخدام هذه ("الشروط") وصولك واستخدامك لتطبيقات "نقلي" على أنظمة ANDROID وIOS (يمكنك تحميله من متاجر جوجل بلاي وآبل ستور) وكافة الصفحات والمحتوى والمعلومات والأدوات والخدمات المتاحة من خلالها ("نقلي")، وهي خدمة تقدمها مؤسسة بيانات الحاسب المسجلة بموجب الأنظمة السعودية، ورقم السجل التجاري [2050180086]، ومقرها الرئيسي [الخرج، طريق الملك عبدالله].يجب أن تقرأ هذه الشروط وسياسة الخصوصية وكافة السياسات المكملة قبل الوصول إلى تطبيق "نقلي" أو استخدامه، إذا كنت لا توافق على هذه الشروط، من فضلك لا تدخل أو تسجل أو تستخدم هذا التطبيق.تشير هذه الشروط إلى سياسة الخصوصيّة والتي تحدّد الممارسات التي نعتمدها لمعالجة أيّ بيانات شخصيّة نجمعها منك أو تزوّدنا بها. أنت توافق على هذه المعالجة وتؤكّد بأنّ كافة البيانات التي تزوّدنا بها صحيحة.',
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
                          "2.التعريفات",
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'a."نقلي": يقصد به تطبيقات "نقلي" لأنظمة ANDROID وiOS وHarmonyOS.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'b."نحن"، "ضمير المتكلم" أو "ضمير الملكية": يقصد بها مؤسسة بيانات الحاسب.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'c."الحساب": يقصد به حساب المستخدم في تطبيق "نقلي"، والذي يمكنه من الاستفادة من خدماته.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'd."المستخدم" أو "أنت" أو "ضمير الملكية للمخاطب": يقصد به كل من يزور تطبيق "نقلي"، أو يُسجل حساب، أو يستخدم التطبيق سواء كان مقدم خدمة أو عميل.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'e.المندوب": يقصد به كل من يسجل حساب في تطبيق "نقلي" (أصحاب الشاحنات)',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'f.العميل": يقصد به كل من يسجل حساب في تطبيق "نقلي"  من خلال التطبيق، ويشار له في هذه الشروط بلفظ الجمع: (العملاء).',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'g.الطرفين": يقصد به المندوب والعميل.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'h."الطلب": يقصد به تقديم طلب من العميل إلى المندوب',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'i."القوانين": يقصد بها الأنظمة السارية في المملكة العربية السعوديّة.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'j."الشروط والأحكام": يقصد بها هذه الشروط وما تتضمنه من بنود إلى جانب سياسة الخصوصية.',
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
                          "3.حساب المستخدم ",
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'a.التسجيل بالاسم الحقيقي، وألا يستخدم اسم مستعار أو مجهول أو مضلل، وفي حالة التسجيل نيابة عن كيان تجاري فيجب تقديم المستندات التي تثبت تفويض من يسجل الحساب أو يستخدم التطبيق بموجب وكالة شرعية عامة أو تفويض مصدّق من الغرف التجارية، ويقر بتحمل مسؤولية استخدام تطبيق "نقلي".',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'b.تقديم بيانات صحيحة ودقيقة وكاملة، والالتزام بتحديثها إذا طرأ عليها أيّ تغيرات.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'c.الحفاظ على سرية بيانات حسابه، وتحمل مسؤولية الإفصاح عن هذه البيانات لأي طرف ثالث.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'd.تقييد الغير من استخدام بيانات حسابه وبالأخص كلمة المرور.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'e.تحمل المسؤولية عن الأنشطة التي تحدث من خلال حسابك وكلمة المرور.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'f.التعاون مع إدارة التطبيق عند طلب أي معلومات إضافية للتحقق من هويته.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'g.الإبلاغ بأي استخدام غير قانوني للحساب أو تعرضه للاختراق أو أي اشتباه في استخدامه.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'h.يتحمّل المستخدم كامل المسؤولية عن أي بيانات أو معلومات مزيفة أو غير صحيحة يقدمها للتطبيق. يحتفظ تطبيق "نقلي" بحقه الكامل في القيام بعمليات التحقق اللازمة للتأكد من متطلبات التسجيل، وبمجرد إتمام التسجيل بنجاح، يستمر تسجيلك لفترة غير محددة ما لم يتم تعليقه أو إلغائه كما هو محدد في هذه الشروط.',
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
                          "4.التأكيدات والضمانات",
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'a.أنك تستوفي شروط صلاحية وأهلية التسجيل، والوفاء بكافة الالتزامات تجاه تطبيق "نقلي".',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'b.قبول شروط الاستخدام وسياسة الخصوصية، والموافقة على الالتزام بكافة بنودها.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'c.عدم القيام بأي تصرف من شأنه التأثير بشكل سلبي على عمل التطبيق أو سمعته أو مصالحه.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'd.عدم استخدام تطبيق "نقلي" لأي سبب قد يتناقض أو يتعارض مع أهدافه وسياساته، أو القوانين السارية.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'e.عدم نقل الحساب إلى مستخدم آخر أو أي طرف آخر دون الحصول على موافقة خطية مسبقة من قبلنا.',
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
                          '5.سياسة الطلب',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'a.نقلي" تطبيق إلكتروني يمكنك تحميله من متاجر جوجل بلاي وآبل ستور تملكه وتديره مؤسسة بيانات الحاسب، يساعد العملاء على طلب خدمات الاعمال لسيارات والشاحنات ',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'b.يسمح تطبيق "نقلي" للعملاء بتقديم طلبات لأنواع الخدمات ، وتحديد الموقع بشكل دقيق، وبعد ذلك يظهر الطلب للمناديب (أصحاب الشاحنات).',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'c.يحدد كل مندوب سعر الخدمة بناءً على ما يراه مناسب ، والموقع الذي حدده العميل، والمسافة.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'd.يختار العميل سعر الخدمة  المناسب والتواصل مع المندوب من خلال التطبيق للاتفاق على تفاصيل الطلب  وتحديد طريقة الدفع.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'e.يلتزم العميل بتحديد بيانات الطلب بشكل صحيح، ومكان توصيل الطلب، والشخص المفوض بالاستلام، ويتم توصيل الطلب مباشرة إلى العنوان المحدد من العميل.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'f.يلتزم العميل بدفع قيمة الطلب من خلال أحد الوسائل التي يوفرها التطبيق.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'g.في حالة قبول المندوب، يدخل الطرفان في علاقة تعاقدية مباشرة وملزمة قانونًا، ويلتزم بتوصيل الطلب إلى الموقع المحدد من العميل.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'h.يلتزم المندوب بإبلاغ إدارة تطبيق "نقلي" في حالة تعذر تقديم الخدمة  إلى العميل لأيّ سبب.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'i.يقر المندوب بتحمل المسؤولية الكاملة عن أخطاء الأشخاص التابعين له أو الأشخاص الذين يستعين بهم في عملية تقديم الخمة ',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'j.يوافق الطرفين على أن الوسيلة الرسمية والمعتمدة للتواصل تكون من خلال نظام نقلي الذي يوفّره تطبيق "نقلي"، وبالتالي يحظر الاتفاق على إبرام أيّ طلبات خارج نطاق التطبيق، وفي حالة مخالفة هذا الالتزام فإنه يحق لإدارة تطبيق "نقلي" تعليق الحساب المخالف سواء بشكل دائم أو مؤقت.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'k.يقتصر دور تطبيق "نقلي" على الربط بين المندوب والعميل مقابل عمولة عن كل خدمة، ومن المعلوم للطرفين بأن تطبيق "نقلي" لا يقوم – سواء بشكل مباشر أو غير مباشر - ببيع أو تقديم خدمة ، وإنما يعد وسيط بين المندوب والعميل',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'l.يقر العميل بأنه متعاقد مستقل مع المندوب فيما يتعلق بالطلب، وأن تطبيق "نقلي" لا يقدم أي ضمانات أو تعهدات فيما يتعلق بالأسعار وعملية التوصيل، ولا يسأل عن أفعال أصحاب الشاحنات.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'm.يقر المندوب بأن تطبيق "نقلي" مجرد وسيط ينتهي دوره بمجرد قبول طلب العميل، وتنصرف كافة الالتزامات المتعلقة بموضوع الطلب إلى طرفيه فقط لا غير.',
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
                          '6.سياسة الدفع',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'a.يوفّر تطبيق "نقلي" الدفع الإلكتروني من خلال وسائل الدفع الالكترونية .',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'b.في حالة الدفع الإلكتروني، يجب إضافة البيانات بشكل صحيح، وتكون المبالغ مستحقة بشكل فوري بمجرد إتمام عملية الدفع، وسيصلك إشعار بتأكيد الدفع على صفحتك بالحساب الخاص بك  المسجل لدينا خلال ، وفي حالة رفض عملية الدفع، فسيتم إبلاغك بالمشكلة، ويمكنك استخدام وسيلة دفع بديلة.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'c.يوافق المستخدم على تحمل كافة رسوم عملية الدفع.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'd.تحتفظ مؤسسة بيانات الحاسب بالحق في تعديل سياسة الدفع في أيّ وقت وفقًا لما تراه مناسبًا وذلك من خلال إضافة وسائل دفع جديدة أو إلغاء أيّ وسيلة حالية.',
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
                          '7.سياسة الرسوم والعمولة',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'a.تسجيل الحساب في تطبيق "نقلي" بدون رسوم، ويحق لنا فرض رسوم مستقبلاً إذا رأينا ضرورة لذلك.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'b.يحصل تطبيق "نقلي" على عمولة من العميل من السعر الاجمالي للطلب عن كل طلب يقدم من خلاله.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'c.يقر ويتعهد العميل بدفع العمولة المستحقة لتطبيق "نقلي".".',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'd.عمولة تطبيق "نقلي" غير قابلة للاسترجاع بعد اتمام الاتفاق بين الطرفين، وفي حال نشوب أي خلافات لاحقة يتحمل الطرفين نتيجة ذلك.',
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
                          '8.تراخيص وقيود الاستخدام',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            "a.تمنحك مؤسسة بيانات الحاسب بموجب هذه الشروط ترخيصاً محدوداً شخصياً غير حصري وغير قابل للتحويل وغير قابل للترخيص من الباطن من أجل تنزيل نسخة من التطبيق على جهازك الذي تملكه أو تتحكم فيه، والوصول إلى المحتوى والمعلومات والمواد ذات الصلة للاستخدام الشخصي وبما يتوافق مع هذه الشروط.",
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'b.نصرّح للمستخدم بالاستخدام المحدود لهذا التطبيق. ويحظر أي استخدام يتجاوز الاستخدامات المسموح بها، فلا يجوز:',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            '1.استخدام التطبيق لانتهاك أي من القوانين السارية، أو التسبب في أضرار أو خسائر لنا.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            '2.ترخيص، أو تأجير، أو بيع، أو نقل، أو توزيع، أو تخصيص، أو استضافة، أو استغلال الخدمة تجارياً',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            '3.فحص أو محاولة استكشاف قوة أو ضعف النظام الأمني للتطبيق، أو اختراق أو محاولة اختراق النظام الأمني للتطبيق، أو التحايل على ميزات التطبيق المتعلقة بالأمان أو تعطيلها أو التدخل فيها بطريقة أخرى.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            '4.محاولة فك رموز، أو برمجة، أو تشفير، أو عكس هندسة أي من البرامج المستخدمة لتوفير التطبيق.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            '5.إعادة إنتاج، أو نسخ، أو بيع، أو إعادة بيع أي جزء من التطبيق، أو استخدامه بصورة مغايرة لأغراض الاستغلال التجاري دون الحصول على موافقة كتابية صريحة منا',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            '6.انتحال شخصية أيّ مستخدم أو كيان، بما في ذلك أيّ موظف أو ممثل لتطبيق "نقلي".',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            '7.استخدام أي علامات وصفية أو نصوص مخفية للعلامة التجارية "نقلي".',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            '8.نشر أو إرسال محتوى غير مرغوب فيه أو غير مصرح به، بما في ذلك المواد الإعلانية أو الترويجية أو "البريد غير الهام" أو "البريد العشوائي" أو "الرسائل المتسلسلة" أو "المخططات الهرمية" أو أيّ شكل آخر.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            '9.نشر، أو نقل، أو إرسال، أو تحميل، سواء بقصد أو دون قصد، أو أية مواد تحتوي على فيروسات أو "أحصنة طروادة" أو "ديدان" أو "قنابل موقوتة" حاسوبية أو أحد برامج رصد لوحة المفاتيح، أو برامج التجسس، أو البرامج المدعومة إعلامياً، أو أي من البرامج الضارة الأخرى، أو أي من الرموز المماثلة التي تهدف إلى التأثير سلباً على تشغيل أي من برامج أو أجهزة الحاسوب.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            '10.إزالة أو إتلاف أيّ من حقوق الطبع والنشر أو العلامات التجارية أو الملكية في تطبيق "نقلي".',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            '11.انتهاك قوانين حقوق النشر، أو العلامة التجارية، أو براءة الاختراع، أو الإعلان، أو قواعد البيانات، أو أي من حقوق الملكية الفكرية التي تتعلق بنا أو المرخصّة لنا أو التي تتعلق بالغير',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'c.لا يشمل الترخيص الممنوح لك أيّ حقوق ملكية على تطبيق "نقلي" أو جزء منه، كما لا يشير هذا الترخيص بشكل مباشر أو غير مباشر لوجود شراكة من أيّ نوع بينك وبيننا فيما يتعلق باستخدامك للتطبيق.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'd.تنتهي التراخيص الممنوحة لك من قِبلنا إذا لم تلتزم بشروط الاستخدام هذه.',
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
                          '9.إخلاء المسؤولية',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'a.يتم توفير تطبيق "نقلي" ومحتواه وخدماته والمعلومات المرتبطة به على أساس ثابت "كما هو" و "كما هو متاح" دون أي ضمانات أو كفالات من أي نوع سواء صريحة أو ضمنية، ويجوز لإدارة تطبيق "نقلي" إجراء أية تغيير، أو تحديث لأي محتوى، أو مادة، أو خدمة على التطبيق.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'b.تخلي مؤسسة بيانات الحاسب مسؤوليتها عن كافة الضمانات من أي نوع (صريحة، أو ضمنية، أو قانونية) فيما يتعلق بهذا التطبيق، بما في ذلك على سبيل المثال لا الحصر، التسويق، أو ملاءمة الاستخدام، أو أي غرض معين.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'c.لا تضمن مؤسسة بيانات الحاسب إتاحة تطبيق "نقلي" في الوقت المحدد بشكل تام وآمن، وعلى الرغم من أننا نسعى لبذل قصارى جهدنا لضمان توافره للاستخدام على مدار الساعة، إلا أنه قد يكون التطبيق غير متوفر من وقت لآخر بسبب أعمال الإصلاح والصيانة الدورية أو التطوير أو بسبب المشكلات الفنية.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'd.لن يتحمل تطبيق "نقلي" مسؤولية الخسائر، أو الأضرار المباشرة، أو غير المباشرة، أو التبعية، أو العرضية الناتجة عن المناديب (أصحاب الشركات ) او مثل الأمور الاتية ',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            '1.الأمور الخارجة عن الإرادة، مثل تعطُل المعدات والأجهزة أو الاتصالات الخاصة بتشغيل التطبيق.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            '2.أيّ روابط خارجية يُمكنك الوصول إليها من خلال التطبيق، أو أيّ محتوى مقدم على هذه الروابط.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'e.لا يضمن تطبيق "نقلي" بأن الإعلانات، أو محتواها، أو صورها، أو أسعارها ستكون دقيقة أو كاملة أو موثوقاً بها أو خالية من الأخطاء، ويتحمل المعلن مسؤولية مراجعة محتوى إعلاناته للتأكد من دقتها وصحتها.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'f.صمم تطبيق "نقلي" بطريقة آمنة وباستخدام أحدث نُظم التشفير لضمان أمان وسرية البيانات، وحيث أنه لا يوجد نظام آمن بنسبة 100%، إلا أنه لن يتحمل تطبيق "نقلي" أية مسؤولية عن أي فيروس أو تلويث أو ميزات مدمرة قد تؤثر على جهاز الجوال نتيجة لاستخدامك أو الوصول أو الانقطاع عن أو عدم القدرة على استخدام التطبيق. ',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'g.بصفتك مستخدم لتطبيق "نقلي"، فأنت توافق على أن المعلومات التي ترسلها لنا صحيحة ودقيقة، ويوافق الطرفين على تحمل مسؤولية البيانات والمعلومات التي يرسلها أو يستلمها كل طرف من خلال التطبيق.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'h.يقر المستخدم بأن تطبيق "نقلي" مجرد وسيط بين الطرفين، وينتهي دوره بقبول وإتمام إجراءات الطلب، وتنصرف كافة الالتزامات المتعلقة بموضوع تنفيذه إلى الطرفين فقط لا غير.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'i.قد نقوم في أي وقت بتعديل أو وقف أو قطع خدمات تطبيق "نقلي" بدون إرسال إخطار إليك بذلك، كما قد نقوم بوقف استخدامك للتطبيق إذا قمت بانتهاك هذه الشروط أو إذا أسأت استخدامه من وجهة نظرنا.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'j.مع عدم الإخلال بحقوق تطبيق "نقلي" الأخرى، فإنه يحق لإدارة التطبيق إيقاف أو إلغاء حساب أي مستخدم، أو تقييد وصوله إلى التطبيق في أي وقت وبدون إشعار ولأي سبب، ودون تحديد.',
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
                          '10.حقوق الملكية الفكرية والعلامة التجارية',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'a.تحتفظ مؤسسة بيانات الحاسب بجميع الحقوق والملكية والمصلحة في تطبيق "نقلي" والأفكار المُعبَر عنها داخله والأجهزة والبرامج والعناصر الأخرى المستخدمة لتوفيره، وحقوق النسخ وبراءات الاختراع وحقوق العلامات والأسرار التجارية والمظهر التجاري والتصاميم، والمحتوى والنصوص والرسومات والأشكال والخطوط والصور ومقاطع الصوت والفيديو والمواد الرقمية، ومجموعات البيانات والبرمجيات وحقوق البرمجة والرموز الأخرى التي يحتوي عليها التطبيق، وهي محمية بموجب قوانين الملكية الفكرية والعلامات التجارية.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'b.الشعارات والكلمات ورؤوس الصفحات وأيقونات الأزرار والأسماء الخدمية المرتبطة بتطبيق "نقلي" هي علامات تجارية وتصميمات تجارية تملكها مؤسسة بيانات الحاسب، ولا يجوز لك إعادة إنتاجها أو استخدامها بأي مكان لأغراض ترويجية سواء بقصد أو عن غير قصد، وأي أسماء أو علامات تجارية أو علامات خدمة تتعلق بالغير، هي ملك لأصحابها المعنيين.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'c.يعد أيّ استخدام غير مصرح به أو نسخ أو تقليد أو تشويه للعلامة التجارية "نقلي" انتهاكًا لحقوقنا الواردة في قوانين حماية العلامات التجارية.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'd.لا يرد في هذه الشروط أو في محتوى التطبيق ما يمكن تفسيره على أنه يمنح بشكل صريح، أو ضمني، أي ترخيص أو حق في استخدام العلامات التجارية لتطبيق "نقلي" دون الحصول على موافقة مسبقة منا.',
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
                          '11.التعويضات',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'a.أنت توافق على تعويض مؤسسة بيانات الحاسب وأي من مسؤوليها وموظفيها ووكلائها عن أي خسائر، أو أضرار، أو مطالبات، أو دعاوى، أو غرامات، أو تكاليف، أو التزامات، أو نفقات أياً كان نوعها أو طبيعتها بما في ذلك الرسوم القانونية وأتعاب المحاماة، والتي تنشأ عن:',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            '1.أيّ ادعاءات أو مطالبات ناتجة عن استخدامك للتطبيق.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            '2.إساءة الاستخدام، أو الاستخدام غير القانوني لتطبيق "نقلي" مهما كان نوعه.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            '3.التزييف في البيانات أو المعلومات التي يقدمها المستخدم لنا.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            '4.تعطل أو توقف التطبيق عن العمل؛ أو عدم تحديثه.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            '5.انتهاكك أو عدم التزامك بشروط الاستخدام وسياسة الخصوصية لتطبيق "نقلي"',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            '6.انتهاكك أيّ من الأنظمة السارية، بما في ذلك قوانين حماية البيانات.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            '7.التعدي على حقوق الملكية الفكرية (حقوق النشر والعلامات التجارية) أو حقوق أخرى للآخرين.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'b.يستثني تطبيق "نقلي" من ضماناته وبنوده وشروطه أي خسائر مالية قد تلحق بالمستخدم، أو تشويه في السمعة، أو أي أضرار خاصة تنشأ عن سوء استخدامه، ولا يتحمل التطبيق أي مسئوليات أو مطالبات في مثل هذه الحالات.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'c.لن يكون تطبيق "نقلي" ومسئوليه وموظفيه مسؤولين قانونًا تجاهك أو تجاه أي طرف آخر عن أي خسارة مباشرة أو غير مباشرة أو عن أي تكلفة أخرى قد تنشأ عن أو فيما يتصل بتنفيذ هذه الشروط، أو تقديم الخدمة.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'd.يحب على المستخدم حماية تطبيق "نقلي وتابعيه وأن يدافع عنهم ويعوضهم عن أية خسائر ناتجة عن أية دعوى أو مطالبة تتعلق بالتطبيق أو ناتجة عن عمل أو إهمال من قِبل المستخدم أو ممثليه أو وكلائه',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'e.يجب على المستخدم تعويضنا عن أي خسائر أو أضرار قد تلحق بالتطبيق نتيجة أي استخدام غير شرعي أو غير مفوض من قِبلنا.',
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
                          '12.الروابط الخارجية',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'a.قد يحتوي تطبيق "نقلي" على روابط لمواقع أخرى تديرها أطراف أخرى غير مؤسسة بيانات الحاسب، نحن لا نؤيد هذه الروابط، ولن نتحمل مسؤولية المحتوى أو المعلومات أو أي مواد أخرى تتوفر على هذه المواقع، وفي حال قررت الوصول إلى أيّ مواقع أخرى، فأنت المسؤول الوحيد عن ذلك.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'b.لا تشكل الروابط الموجودة على تطبيق "نقلي" موافقة منا على استخدام مثل هذه الروابط، ولا يقدم تطبيق "نقلي" أيّ ضمانات أو تعهدات أياً كان نوعها فيما يتعلق بهذه الروابط الخارجية وما يتعلق بها.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'c.يرجى مراجعة سياسات الخصوصية لمواقع الأطراف الأخرى قبل استخدامها وتقديم بياناتك لها.',
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
                          '13.الاتصالات الإلكترونية',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'a.قد نتواصل مع المستخدم عن طريق البريد الإلكتروني المسجل في تطبيق "نقلي" فيما يتعلق بتحديثات هذه الشروط والخصوصية، والرسائل الإدارية والإشعارات الفنية وتنبيهات الأمان، ويوافق المستخدم على أن كل الاتصالات الإلكترونية تستوفي كافة الشروط وتفي بجميع المتطلبات القانونية كما لو كانت هذه الاتصالات مكتوبة.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'b.قد نتواصل مع المستخدم لأغراض ترويجية، فيما يتعلق بأي تغييرات أو ميزات أو أنشطة جديدة تضاف إلى التطبيق. في حال قرر المستخدم في أي وقت عدم استقبال أو استلام مثل هذه الاتصالات، يمكنه إيقاف استلام هذه الرسائل بالنقر على رابط إلغاء الاشتراك أسفل الرسالة الإلكترونية.',
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
                          '14.المدة والإنهاء',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'a.تكون مدة هذه الشروط محددة بفترة تسجيلك حساب واستخدامك للتطبيق، وتظل سارية ما لم يتم إنهاؤها من طرفنا أو طرفك.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'b.يحق لـ مؤسسة بيانات الحاسب إنهاء هذه الشروط على الفور، في حال توفر أي من الحالات التالية:',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            '1.انتهاك هذه الشروط، أو سياسة الخصوصية، أو قواعد استخدام تطبيق "نقلي".',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            '2.إذا ثبت لنا إساءتك باستخدام التطبيق، أو تسبب استخدامك لتطبيق "نقلي" بأيّ مشكلات قانونية لنا.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'c.يحق للمستخدم إنهاء هذه الشروط في أيّ وقت عن طريق التوقف عن استخدام التطبيق أو إلغاء تثبيته من على الجوال؛ وعند الإنهاء أو الإلغاء، ستتوقف كافة التراخيص الممنوحة للمستخدم بموجب هذه الشروط.',
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
                          '15.التعديلات في الشروط',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'a.يحق لـ مؤسسة بيانات الحاسب تعديل، أو تحديث، أو إكمال، أو استبدال، أو حذف أي شرط من هذه الشروط، ويلتزم المستخدم بالتعديلات التي تجريها وتراها لازمة.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'b.تسري جميع التعديلات فور نشرها على تطبيق "نقلي"، وتنطبق على كل استخداماتك بعد ذلك.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'c.يحق لـ مؤسسة بيانات الحاسب تغيير أو تعليق أو إيقاف الخدمة التي تقدمها من خلال تطبيق "نقلي"، أو إجراء تعديلات أو تحسينات على التطبيق أو إضافة بعض الميزات لزيادة فاعليته، ويلتزم المستخدم بأية توجيهات أو تعليمات يقدمها تطبيق "نقلي" إليه في هذا الخصوص.',
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
                          '16.الاختصاص القضائي',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'a.تخضع وتفسر هذه الشروط وفقًا للقوانين السارية في المملكة العربية السعوديّة.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'b.إذا وجدت محكمة أو جهة حكومية ما في المملكة العربية السعوديّة أن أي جزء من الشروط غير قابل للتنفيذ أو غير ساري، فيعتبر هذا الجزء قابلاً للفصل ومحذوفًا من هذه الشروط، وستظل بقية البنود سارية المفعول.',
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
                          '17.تحويل الحقوق والالتزامات',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'a.يحق لـ مؤسسة بيانات الحاسب تحويل أو نقل كافة حقوقها أو التزاماتها المنصوص عليها في هذه الشروط إلى أيّ طرف ثالث دون اعتراض منك بشرط أن يوافق هذا الطرف الثالث على الالتزام بهذه الشروط.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'b.يحظر على المستخدم التنازل عن كل أو أي من التزاماته أو حقوقه بموجب هذه الشروط إلى أيّ طرف ثالث، أو أن تفويض أي طرف آخر بخلاف ما هو مسموح بإدارة حسابه دون موافقة كتابية وصريحة منا.',
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
                          '18.القوة القاهرة',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'لن تتحمّل مؤسسة بيانات الحاسب مسئولية أيّ تأخير أو إخفاق في أداء أيّ من التزاماتها بموجب هذه الشروط متى كان ذلك ناتجاً عن القوة القاهرة أو الظروف الطارئة والتي تؤدي إلى تعطيل عمل التطبيق بشكل طبيعي.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '19.علاقة الأطراف',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'لن تفسّر بنود هذه الشروط بوجود علاقة شراكة أو مشروع مشترك أو وكالة بين مؤسسة بيانات الحاسب وبين أي مستخدم (سواء كان مندوب أو عميل) أو أي طرف ثالث، ولا يحق لأي طرف إلزامنا بأيّ شيء وبأي شكل.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '20.التعارض',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'في حال تعارضت هذه الشروط مع أيّ من إصدارات سابقة لها، فإنّ النسخة الحالية تكون هي السائدة.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '21.الإخطار',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'يجوز لتطبيق "نقلي" إرسال إخطار للمستخدم من خلال إشعارات التطبيق، أو البريد الإلكتروني المسجل.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '22.اللغة',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '22.كُتبت هذه الشروط باللغة العربيّة، وفي حال تُرجمت إلى لغة أجنبيّة أخرى فإنّ النص العربي هو الذي يُعتد به.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '23.الاتفاق الكامل',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'تشكل هذه الشروط وسياسة الخصوصية (أو النسخ المعدّلة) كامل الاتفاق بينك (المندوب والعميل) وبين تطبيق "نقلي" الصادر عن مؤسسة بيانات الحاسب، وتحل محل أيّ إصدارات سابقة من هذه الشروط.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '24.التواصل معنا',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'إذا كان لديك أي أسئلة بشأن هذه الشروط، أو الممارسات المتعلقة بتطبيق "نقلي"، فلا تتردد في التواصل معنا على الموقع الالكتروني ',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'حقوق الطبع والنشر © "نقلي" 2024',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'جميع الحقوق محفوظة لـ مؤسسة بيانات الحاسب',
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
                      ['These Terms of Use ("Terms") govern your access to and use of the Naqlee applications for Android and iOS (downloadable from the Google Play and Apple Stores) and all pages, content, information, tools, and services available through them ("Naqlee"). This service is provided by Computer Data Corporation, registered under Saudi laws, with commercial registration number [2050180086], and headquartered in [Al-Kharj, King Abdullah Road].',
                        'You must read these Terms, the Privacy Policy, and all supplementary policies before accessing or using the Naqlee App. If you do not agree to these Terms, please do not access, register, or use this App.',
                        'These Terms refer to the Privacy Policy, which outlines our practices for processing any personal data we collect from you or provide to us. You consent to such processing and confirm that all data you provide to us is accurate.'],
                  ),

                  privacyPolicy('2. Definitions', [
                    'In these Terms, unless the context otherwise requires, the following terms have the meanings indicated:',
                    'a  "Naqlee": refers to the "Naqlee" applications for Android, iOS, and HarmonyOS.',
                    'b  "We," "us," or "our": refers to Computer Data Corporation.',
                    'c  "Account": refers to the users account in the Naqlee application, which enables them to benefit from its services.',
                    'd  "User," "You," or "Your": refers to anyone who visits the "Naqlee" application, registers an account, or uses the application, whether as a service provider or a customer.'
                    'e  "Delegate": refers to anyone who registers an account in the "Naqlee" application (truck owners).',
                    'f  "Customer": refers to anyone who registers an account in the "Naqlee" application through the application, and is referred to in these terms as "Customers."',
                    'g  "Parties": refers to the delegate and the customer.',
                    'h  "Order": refers to the customer submitting an order to the delegate.',
                    'i  "Laws": means the laws in force in the Kingdom of Saudi Arabia.',
                    'j  "Terms and Conditions": means these Terms and the provisions thereof, along with the Privacy Policy.'
                  ]),

                  privacyPolicy('3. User Account', [
                    'In order to use the "Naqlee" application, the user must register an account and agree to:',
                    'a. Register using their real name and not using a pseudonym, anonymous name, or misleading name. If registering on behalf of a commercial entity, they must provide documents proving the authorization of the account registrant or user of the application, based on a general legal power of attorney or a certified authorization from the Chambers of Commerce. They acknowledge their responsibility for using the "Naqlee" application.',
                    'b. Provide true, accurate, and complete information and commit to updating it if any changes occur.',
                    'c. Maintain the confidentiality of their account information and assume responsibility for disclosing this information to any third party.',
                    'd. Restrict third parties from using their account information, particularly their password.',
                    'e. Assume responsibility for activities that occur through their account and password.',
                    'f. Cooperate with the application administration when requested for any additional information to verify your identity.',
                    'g. Report any illegal use of your account, hacking, or suspected misuse.',
                    'h. The user bears full responsibility for any false or incorrect data or information they provide to the application.',
                    'The "Naqlee" application reserves the right to conduct the necessary verifications to verify registration requirements. Once registration is successfully completed, your registration will continue for an indefinite period unless suspended or canceled as specified in these terms.'
                  ]),

                  privacyPolicy('4. Representations and Warranties', [
                    'Once you register an account with the "Naqlee" application in accordance with the registration provisions mentioned above, you undertake the following:',
                    'a. That you meet the registration eligibility and validity requirements and fulfill all obligations towards the "Naqlee" application.',
                    'b. Accept the Terms of Use and Privacy Policy and agree to abide by all of its provisions.',
                    'c. Not to take any action that would negatively affect the application\'s business, reputation, or interests.',
                    'd. Not to use the Naqlee app for any reason that may conflict with or contradict its objectives, policies, or applicable laws.',
                    'e. Not to transfer your account to another user or any other party without our prior written consent.'
                  ]),

                  privacyPolicy('5. Order Policy', [
                    'a. "Naqlee" is an electronic application that can be downloaded from the Google Play and Apple Stores. It is owned and operated by Data Computers. It helps customers order business services for cars and trucks.',
                    'b. The "Naqlee" application allows customers to submit requests for various types of services, specifying a precise location. The request is then displayed to the representatives (truck owners).',
                    'c. Each representative determines the service price based on what they deem appropriate, the location specified by the customer, and the distance.',
                    'd. The customer selects the appropriate service price and communicates with the representative through the application to agree on the order details and determine the payment method.',
                    'e. The customer is obligated to correctly specify the order information, the delivery location, and the authorized person to receive it. The order will be delivered directly to the address specified by the customer.',
                    'f. The customer is obligated to pay the order value through one of the methods provided by the application.',
                    'g. If the representative accepts, the two parties enter into a direct and legally binding contractual relationship, and the representative is obligated to deliver the order to the location specified by the customer.',
                    'h. The representative is obligated to notify the "Naqlee" application management if the service cannot be provided to the customer for any reason.',
                    'i. The representative acknowledges full responsibility for errors made by his or her subordinates or those he or she uses in the service delivery process.',
                    'j. Both parties agree that the official and approved means of communication is through the "Naqlee" system provided by the "Naqlee" application. Therefore, it is prohibited to conclude any orders outside the scope of the application. In the event of a violation of this obligation, the "Naqlee" application management has the right to suspend the offending account, either permanently or temporarily.',
                    'k. The role of the "Naqlee" application is limited to connecting the representative and the customer in exchange for a commission for each service. Both parties understand that the "Naqlee" application does not, directly or indirectly, sell or provide a service, but rather acts as an intermediary between the representative and the customer.',
                    'l. The customer acknowledges that he or she is an independent contractor with the representative regarding the order, and that the "Naqlee" application does not provide any guarantees or commitments regarding prices or the delivery process, and is not responsible for the actions of truck owners.',
                    'm. The representative acknowledges that the "Naqlee" application is merely an intermediary whose role ends once the customer\'s order is accepted. All obligations related to the subject of the order are solely the responsibility of the two parties.',
                  ]),

                  privacyPolicy('6. Payment Policy', [
                    'a. The "Naqlee" application provides electronic payment through electronic payment methods.',
                    'b. In the case of electronic payment, the data must be entered correctly, and amounts are due immediately upon completion of the payment process. You will receive a notification confirming the payment on your page in your account registered with us within 30 days. If the payment process is rejected, you will be notified of the problem, and you may use an alternative payment method.',
                    'c. The user agrees to bear all payment transaction fees.',
                    'd. Computer Data Foundation reserves the right to amend the payment policy at any time as it deems appropriate, by adding new payment methods or canceling any existing method.',
                  ]),

                  privacyPolicy('7. Fees and Commission Policy', [
                    'a. Registering an account with the Naqlee app is free of charge. We reserve the right to impose fees in the future if we deem it necessary.',
                    'b. The Naqlee app receives a commission from the customer based on the total order price for each order submitted through it.',
                    'c. The customer acknowledges and undertakes to pay the commission due to the Naqlee app.',
                    'd. The Naqlee app commission is non-refundable after the agreement is concluded between the two parties. In the event of any subsequent disputes, both parties shall bear the resulting costs.',
                  ]),

                  privacyPolicy('8. Licenses and Restrictions on Use', [
                    'a. Computer Data Foundation grants you a personal, limited, non-exclusive, non-transferable, non-sublicensable license under these Terms to download a copy of the Application to a device you own or control and access related content, information, and materials for your personal use and in accordance with these Terms.',
                    'b. We authorize the User to make limited use of this Application. Any use beyond the permitted uses is prohibited. You may not:',
                    'c. Use the Application to violate any applicable law or cause us damage or loss.',
                    'd. License, rent, sell, transfer, distribute, assign, host, or otherwise commercially exploit the Service.',
                    'e. Probe or attempt to probe the strength or weakness of the Application\'s security system, penetrate or attempt to penetrate the Application\'s security system, or circumvent, disable, or otherwise interfere with the security-related features of the Application.',
                    'f. Attempt to decipher, decompile, code, or reverse engineer any of the software used to provide the Application.',
                    'g. Reproduce, copy, sell, resell, or otherwise exploit any portion of the Application for commercial purposes without our express written consent.',
                    'h. Impersonate any user or entity, including any employee or representative of the Naqlee Application.',
                    'i. Use any meta tags or hidden text for the Naqlee trademark.',
                    'j. Post or transmit any unsolicited or unauthorized content, including advertising, promotional materials, "junk mail," "spam," "chain letters," "pyramid schemes," or any other form of solicitation.',
                    'k. Post, transmit, send, or upload, whether intentionally or unintentionally, any material that contains computer viruses, Trojan horses, worms, time bombs, keyloggers, spyware, media-supported programs, or any other harmful programs or similar code intended to adversely affect the operation of any computer software or hardware.',
                    'l. Remove or destroy any copyright, trademark, or proprietary notices in the Naqlee App.',
                    'm. Violate any copyright, trademark, patent, advertising, or database laws or any other intellectual property rights belonging to us, licensed to us, or belonging to a third party.',
                    'n. The license granted to you does not include any ownership rights in the Naqlee App or any part thereof, nor does this license directly or indirectly imply a partnership of any kind between you and us with respect to your use of the App.',
                    'o. The licenses granted to you by us terminate if you fail to comply with these Terms of Use.',
                  ]),

                  privacyPolicy('9. Disclaimer', [
                    'a. The Naqlee App, its content, services, and related information are provided on an "as is" and "as available" basis without any warranties or guarantees of any kind, either express or implied. The Naqlee App may make any changes or updates to any content, materials, or service on the App.',
                    'b. Computer Data Foundation disclaims all warranties of any kind (express, implied, or statutory) with respect to this App, including, but not limited to, warranties of merchantability, fitness for a particular purpose, or non-infringement.',
                    'c. Computer Data Foundation does not guarantee that the Naqlee App will be available on time, fully accessible, and secure. Although we endeavor to ensure its availability around the clock, the App may be unavailable from time to time due to repairs, periodic maintenance, development, or technical issues.',
                    'd. The Naqlee App will not be liable for any direct, indirect, consequential, or incidental losses or damages resulting from the representatives (business owners) or the following:',
                    'e. Matters beyond its control, such as malfunctions of equipment, devices, or communications necessary for the operation of the App.',
                    'f. Any external links you may access through the App, or any content provided through these links.',
                    'g. The Naqlee App does not guarantee that advertisements, their content, images, or prices will be accurate, complete, reliable, or error-free. It is the advertiser\'s responsibility to review the content of their advertisements to ensure their accuracy and correctness.',
                    'h. The Naqlee App is designed securely, using the latest encryption systems to ensure the security and confidentiality of data. While no system is 100% secure, the Naqlee App will not be liable for any viruses, contamination, or destructive features that may affect your mobile device as a result of your use, access, interruption, or inability to use the App.',
                    'i. As a user of the Naqlee App, you agree that the information you provide to us is true and accurate, and both parties agree to bear responsibility for the data and information they send or receive through the App.',
                    'j. The User acknowledges that the Naqlee App is merely an intermediary between the two parties, and its role ends with the acceptance and completion of the order process. All obligations related to its implementation are solely the responsibility of both parties.',
                    'k. We may modify, suspend, or discontinue the Naqlee App services at any time without notice to you. We may also terminate your use of the App if you violate these Terms or, in our opinion, misuse the App.',
                    'l. Without prejudice to the other rights of the “Naqlee” application, the application management has the right to suspend or cancel any user’s account, or restrict his access to the application at any time, without notice, for any reason, and without limitation.',
                  ]),

                  privacyPolicy('10. Intellectual Property Rights and Trademarks', [
                    'a. Computer Data Foundation reserves all rights, title, and interest in and to the Naqlee App, the ideas expressed within it, and the hardware, software, and other elements used to provide it, as well as copyrights, patents, trademark rights, trade secrets, trade dress, and designs, and the content, text, graphics, forms, fonts, images, audio and video clips, digital materials, data compilations, software, programming rights, and other code contained in the App, which are protected by intellectual property and trademark laws.',
                    'b. The logos, words, page headers, button icons, and service names associated with the Naqlee App are trademarks and trade dress owned by Computer Data Foundation. You may not reproduce or use them anywhere for promotional purposes, whether intentionally or unintentionally. Any names, trademarks, or service marks associated with third parties are the property of their respective owners.',
                    'c. Any unauthorized use, copying, imitation, or distortion of the "Naqlee" trademark is a violation of our rights under trademark protection laws.',
                    'd. Nothing in these Terms or in the Application Content shall be construed as granting, expressly or impliedly, any license or right to use the "Naqlee" trademarks without our prior consent.',
                  ]),

                  privacyPolicy('11. Indemnification', [
                    'a. You agree to indemnify Computer Data Corporation and any of its officers, employees, and agents from any and all losses, damages, claims, suits, fines, costs, liabilities, and expenses of any kind or nature, including legal fees and attorneys\' fees, arising from:',
                    'b. Any claims or demands resulting from your use of the Application.',
                    'c. Misuse or unlawful use of the "Naqlee" Application of any kind.',
                    'd. Falsification of data or information provided by the user to us.',
                    'e. The application malfunctioning or being discontinued, or not updated.',
                    'f. Your violation of or failure to comply with the Terms of Use and Privacy Policy of the Naqlee application.',
                    'g. Your violation of any applicable laws, including data protection laws.',
                    'h. Infringement of intellectual property rights (copyright and trademarks) or other rights of others.',
                    'i. The Naqlee application excludes from its warranties, terms, and conditions any financial losses, damage to reputation, or any special damages incurred by the user due to misuse, and shall not bear any responsibilities in such cases.',
                    'j. The Naqlee App, its officers and employees, will not be legally liable for any direct or indirect loss arising from or in connection with the implementation of these Terms or the provision of the Service.',
                    'k. The User shall protect, defend, and indemnify the Naqlee App and its affiliates against any losses resulting from any claim or demand related to the App or resulting from the act or negligence of the User, their representatives, or agents.',
                    'l. The User shall indemnify us for any losses or damages incurred by the App due to any illegal or unauthorized use.',
                  ]),

                  privacyPolicy('12. External Links', [
                    'a. The Naqlee App may contain links to other websites operated by parties other than Computer Data Foundation. We do not endorse these links and are not responsible for the content or materials on these websites.',
                    'b. The links on the Naqlee App do not constitute our endorsement and we make no warranties or representations regarding these external links.',
                    'c. Please review the privacy policies of third-party websites before using them or submitting your data.',
                  ]),

                  privacyPolicy('13. Electronic Communications', [
                    'a. We may communicate with the User via the email address registered in the Naqlee App regarding updates to these Terms and Privacy Policy, administrative messages, technical notices, and security alerts.',
                    'b. The User agrees that all electronic communications meet legal requirements as if they were in writing.',
                    'c. We may contact the User for promotional purposes. Users can opt out at any time by clicking the unsubscribe link in the email.',
                  ]),

                  privacyPolicy('14. Term and Termination', [
                    'a. The term of these Terms is limited to your account registration and use of the Application unless terminated by either party.',
                    'b. Computer Data Foundation may terminate these Terms immediately if you violate the Terms, Privacy Policy, or the Application Usage Rules.',
                    'c. The User may terminate these Terms at any time by discontinuing use of the Application; upon termination, all licenses granted to the User will cease.',
                  ]),

                  privacyPolicy('15. Amendments to the Terms', [
                    'a. Computer Data Foundation may amend, update, supplement, replace, or delete any provision of these Terms.',
                    'b. All amendments shall be effective immediately upon posting on the Naqlee App and shall apply to all of your use thereafter.',
                    'c. Computer Data Foundation may change, suspend, or discontinue services provided through the Naqlee App or modify features.',
                  ]),

                  privacyPolicy('16. Jurisdiction', [
                    'a. These Terms shall be governed by and construed in accordance with the laws of the Kingdom of Saudi Arabia.',
                    'b. If any part of the Terms is found to be unenforceable or invalid, that part shall be deleted, and the remaining provisions shall remain in effect.',
                  ]),

                  privacyPolicy('17. Transfer of Rights and Obligations', [
                    'a. Computer Data Foundation may assign or transfer all of its rights or obligations under these Terms to any third party without your objection.',
                    'b. The User shall not assign or transfer any of its obligations or rights without our express written consent.',
                  ]),

                  privacyPolicy('18. Force Majeure', [
                    'Computer Data Foundation shall not be liable for any delay or failure to perform any obligations under these Terms if such delay results from force majeure or unforeseen circumstances.',
                  ]),

                  privacyPolicy('19. Relationship of the Parties', [
                    'a. These Terms do not create a partnership, joint venture, or agency relationship between Computer Data Foundation and the user.',
                    'b. Neither party shall have the right to bind the other in any way or form.',
                  ]),

                  privacyPolicy('20. Conflict', [
                    'If these Terms conflict with any prior versions, the current version shall prevail.',
                  ]),

                  privacyPolicy('21. Notice', [
                    'Naqlee may send notice to the user via in-app notifications or registered email.',
                  ]),

                  privacyPolicy('22. Language', [
                    'These Terms are written in Arabic. If translated into another language, the Arabic text shall prevail.',
                  ]),

                  privacyPolicy('23. Entire Agreement', [
                    'These Terms and the Privacy Policy constitute the entire agreement between you and Computer Data Foundation and supersede any prior versions.',
                  ]),

                  privacyPolicy('24. Contact Us', [
                    'If you have any questions about these Terms or the Naqlee App practices, please contact us through the website.',
                  ]),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Copyright © "Naqlee" 2024',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                          "1.المقدّمة",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'a.تشكل سياسة الخصوصية هذه ("السياسة") عقدًا قانونيًا ملزمًا وقابل للتنفيذ بينك ("المستخدم") وبين مؤسسة بيانات الحاسب (المالك والمشغل والمتحكِم والمسؤول عن سياسة الخصوصية في تطبيق "نقلي")، لذا يرجى قراءتها بعناية تامة قبل استخدام التطبيق.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'b.نحترم خصوصية جميع المستخدمين، ونلتزم بحماية بياناتهم الشخصيّة، لذلك أعددنا هذه السياسة لتساعدك على فهم الإجراءات والممارسات التي تتبعها مؤسسة بيانات الحاسب عند جمع واستخدام ومشاركة البيانات الشخصيّة، وكيفية تأمين هذه البيانات، والتعامل معها عند زيارة واستخدام تطبيق "نقلي".',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "2.الموافقة على السياسة",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'a.بوصولك أو استخدامك لتطبيق "نقلي"، فأنت تقر بأنك قرأت هذه السياسة وشروط الاستخدام ("الشروط والأحكام") وتوافق صراحة على الالتزام بجميع البنود الواردة فيها. ',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'b.باستخدامك لتطبيق "نقلي" أو إجراء طلبات من خلاله، فأنت توافق صراحةً على طريقة جمع واستخدام ومعالجة وتخزين بياناتك الشخصيّة بموجب هذه السياسة، والسماح لنا بالتواصل معك لإبلاغك بمعلومات حول الخدمات والمنتجات التي قد تهمك، والموافقة على أيّ تغييرات نجريها مستقبلاً في سياسة الخصوصية. إذا كنت توافق على الممارسات الموضحة في هذه السياسة، فلا يجوز لك استخدام هذا التطبيق.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "3.نطاق السياسة",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(40, 8, 8, 0),
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'a.تنطبق هذه السياسة على كل من يزور أو يتصفح أو يستخدم تطبيق "نقلي" بما في ذلك المعلومات والبيانات والخدمات والأدوات وجميع الصفحات والأنشطة الأخرى التي نقدمها على التطبيق أو من خلاله.',
                                textAlign: TextAlign.left,
                              )),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            'b.لا تنطبق هذه السياسة على أيّ مواقع أو تطبيقات أو خدمات أخرى تابعة لجهات خارجية ترتبط بتطبيق "نقلي"، ولا تنطبق على المعلومات المقدّمة أو المجمعة من خلال المواقع التي تحتفظ بها شركات أو مؤسسات أخرى.',
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
                          "4.المبادئ العامة للخصوصية",
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                          child: Text(
                            'a.نشر وتحديث هذه السياسة -كلما كان لازماً- لتوضيح الممارسات المتّبعة عند استخدام تطبيق "نقلي".',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            "b.جمع واستخدام البيانات الشخصيّة وفقاً للأغراض المحددة في هذه السياسة.",
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            "c.معالجة البيانات الشخصيّة بما يتوافق مع أغراض الجمع والاستخدام والمشاركة.",
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            "d.اتخاذ خطوات معقولة للتأكد وضمان أن المعلومات الشخصيّة موثوقة، ودقيقة، وكاملة، ومحدّثة.",
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            "e.اتخاذ إجراءات مناسبة لتوفير حماية كافية للبيانات التي يتم الإفصاح عنها لأطراف أخرى.",
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
                          "5.طرق جمع البيانات",
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
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'a.التفاعلات المباشرة',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '1.بيانات الحساب: عند تسجيل حساب في تطبيق "نقلي"، يقدم لنا المستخدم بيانات محددة، تشمل: الاسم، والبريد الالكتروني، ورقم الجوال، وأي بيانات إضافية تطلبها إدارة التطبيق.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '2.بيانات التواصل: عند التواصل معنا من خلال الوسائل المتاحة في التطبيق، أو الرد على الرسائل التي تصلك على البريد الإلكتروني، مثل اسم المستخدم، والبريد الإلكتروني، وعنوان الرسالة، والموضوع.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '3.بيانات الطلب: عند تقديم طلب شراء لأحد المنتجات من خلال تطبيق "نقلي"، فإننا نجمع بيانات الطلب مثل اسم المستلم، والنوع، والكمية، والمبلغ الإجمالي للطلب، ورقم الهاتف، وعنوان الشحن والفواتير، وأي بيانات أخرى نراها ضرورية أو مطلوبة بموجب الأنظمة واللوائح المعمول بها.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '4.بيانات الدفع: عند دفع مقابل الطلبات، فإنه يجب على العميل دفع مقابلها من خلال أحد الوسائل المتاحة بالتطبيق، ويتم تقديم بيانات الدفع إلى مزودي خدمات الدفع المتعاقد معها لمعالجة عملية الدفع.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '5.بيانات الاشتراك: عند الاشتراك في النشرات البريدية، أو إكمال أي نماذج أخرى يوفرها التطبيق.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        '6.بيانات المشاركات: عند إضافة الملاحظات، أو الآراء، أو التعليقات.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        "b.التفاعلات الآلية",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "1.البيانات التقنية: وتشمل عنوان بروتوكول (IP) لربط جهازك بشبكة الانترنت، ونوع المتصفح، وصفحات الإحالة/الخروج، ومزوّد خدمة الإنترنت، ومعرّفات الجهاز، ومعرّف الإعلان، ونظام التشغيل، وأنواع الوظائف الإضافية، والتاريخ ووقت الوصول، وعدد النقرات، ومعلومات حول استخدام خدماتنا، والبيانات المتعلقة بالأجهزة المتصلة بالشبكة.",
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                          child: Text(
                            "2.بيانات السجل: وتشمل بيانات سجلات الجهاز وأدوات تحليلات الاستخدام الداخلي، والمنتجات التي شاهدتها أو تبحث عنها، وأوقات استجابة الصفحة، ومدة الزيارات إلى صفحات معينة، ومعلومات تفاعل الصفحة، وبيانات الموقع الجغرافي، وأي رقم هاتف مستخدم للاتصال برقم خدمة العملاء لدينا.",
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            "3.البيانات الجغرافية التقريبية: مثل الدولة والمدينة والإحداثيات الجغرافية، محسوبة على أساس عنوان IP الخاص بك، أو تحديد الموقع الجغرافي من قبل العميل.",
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            "4.بيانات تقنيات التتبع: وتشمل ملفّات تعريف الارتباط (الكوكيز)، وبكسل التتبع، وإشارات الويب لجمع وتخزين بياناتك الشخصيّة ذات الصلة.",
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        "c.الأطراف الثالثة",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                          child: Text(
                            "1.بيانات من الشركاء: مثل شركاء التسويق والإعلانات وغيرها من الجهات الأُخرى.",
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                          child: Text(
                            "2.بيانات من شبكات التواصل الاجتماعي: مثل فيسبوك وتويتر وغيرها.",
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
                          "6.أغراض استخدام البيانات",
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
                        "a.مساعدة المستخدم في إنشاء الحساب، والتحقق من الهوية، وتسجيل الدخول إلى الحساب.",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        "b.تعزيز أعمالنا، بما في ذلك تحسين محتوى ووظائف التطبيق، وتقديم خدمة أفضل للعملاء.",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        "c.تزويد المستخدم بالدعم الفني، والرد على الأسئلة والاستفسارات ورسائل البريد الإلكتروني.",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        "d.إرسال الرسائل الإدارية المتعلقة بالخدمة وإبلاغك وتنبيهك ومعلومات حول تحديثات سياسة الخصوصية، أو تأكيدات الحساب، أو تحديثات الأمان، أو النصائح، أو غيرها من المعلومات ذات الصلة",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        "e.تقديم مقترحات وتوصيات للمستخدم بشأن الخدمات والمنتجات التي تهمه بناءً على نشاطه في التطبيق.",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        "f.تحسين الخدمات، بما في ذلك عن طريق تخصيص تجربة المستخدم.",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        "g.منع الأنشطة المحظورة أو غير القانونية، والامتثال للأنظمة السارية، وفرض شروطنا وأي أغراض أخرى تم الكشف عنها لك في الوقت الذي نجمع فيه معلوماتك أو وفقاً لموافقتك.",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        "h.إجراء أبحاث السوق والدراسات الاستقصائية، وللأغراض الإحصائية والبحثية، والتحليلية، والترويجية.",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "7.مشاركة البيانات",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        "a.نشارك البيانات الشخصيّة التي نجمعها وفقاً لهذه السياسة مع الشركات التابعة لنا ومع الأطراف الثالثة الأخرى لتحقيق الأغراض المنصوص عليها في القسم [6] من هذه السياسة، وبناءً عليه يجوز لنا مشاركة البيانات في الحالات التالية:",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "1.بموافقتك: قد نشارك بياناتك إذا منحتنا موافقة محددة على استخدام بياناتك الشخصيّة لغرض محدد.",
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "2.المصالح المشروعة: قد نشارك بياناتك عندما تكون ضرورية لتحقيق مصالحنا المشروعة",
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "3.أداء العقد: قد نشارك بياناتك الشخصيّة للوفاء بشروط عقدنا معك.",
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "4.الالتزامات القانونية: قد نشارك بياناتك عندما يكون مطلوبًا القيام بذلك بموجب أمر من المحكمة، أو عندما يكون علينا واجب الكشف عن بياناتك أو مشاركتها من أجل الامتثال لأي التزام قانوني.",
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "5.الاهتمامات الحيوية: قد نشارك بياناتك عندما نعتقد أنه من الضروري التحقيق أو منع أو اتخاذ إجراء بشأن الانتهاكات المحتملة لسياساتنا، أو الاحتيال المشتبه به، أو المواقف التي تنطوي على تهديدات محتملة لسلامة أي شخص وأنشطة غير قانونية، أو كدليل في التقاضي الذي نشارك فيه.",
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '6.أصحاب الشاحنات: عندما تقدم طلب عمل للمسجلين في تطبيق "نقلي"، فإننا نشارك بعض بيانات المستخدم مع طالب الخدمة  من أجل تسهيل عملية تنفيذ  الطلب.',
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '7.معالجة المدفوعات: عند إجراء عملية دفع للطلبات من خلال تطبيق "نقلي"، فقد يطلب من المستخدم تقديم بيانات محددة تتعلق بالدفع الإلكتروني لإتمام عملية الدفع، ويوافق المستخدم صراحةً على أنه يحق لنا مشاركة بياناته مع معالجي الدفع لتسهيل عملية الدفع (بما في ذلك على سبيل المثال لا الحصر، مقدّمي خدمات الكشف عن الاحتيال).',
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "8.العروض التسويقية والترويجية: يجوز لنا مشاركة البيانات مع الكيانات التي تساعدنا في أعمال التسويق والتعريف بخدماتنا والتطوير المستمر وتعزيز تجربته على التطبيق.",
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "9.نقل الأعمال: في حالة حدوث أيّ انتقال أو تغيير في أعمال مؤسسة بيانات الحاسب، فإنه يجوز لنا مشاركة البيانات مع طرف ثالث فيما يتعلق بأيّ عملية اندماج، أو استحواذ، أو إعادة تنظيم، أو بيع الأصول، أو مشروع مشترك، أو التنازل، أو التحويل، أو أي تصرف مشابه لكل أو جزء من أعمالنا أو أصولنا أثناء المفاوضات، فقد يتم بيع بياناتك أو نقلها كجزء من تلك المعاملة، وللكيان الجديد استخدام البيانات بنفس الطريقة المنصوص عليها في هذه السياسة.",
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        "b.أنت تمنحنا الحق في السماح لموظفينا وشركاء الأعمال معنا بالتعامل مع بياناتك الشخصيّة في حدود تقديم الخدمات. يرجى ملاحظة أن استخدام أي أطراف ثالثة لبياناتك سيخضع لسياسات الخصوصية الخاصة بها؛ نوصيك بمراجعة سياسات الخصوصية بعناية للأطراف الثالثة.",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "8.تخزين البيانات والاحتفاظ بها",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'a.يخزن تطبيق "نقلي" البيانات الشخصيّة للمستخدمين طالما أنها ضرورية لتحقيق الأغراض المحددة في القسم [6]، ويحق لنا الاحتفاظ بها لإعادة النظر في سياسة الخصوصية الحالية، أو عندما تتطلب الأنظمة السارية في بعض الأحيان الاحتفاظ بتلك البيانات لفترة زمنية أطول لأغراض الامتثال للأنظمة التي نخضع لها أو للدفاع عن الدعاوى المرفوعة ضدنا.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'b.يحتفظ تطبيق "نقلي" بالبيانات المرتبطة بالحسابات في سجلات إلكترونية طالما كان لديك حساب نشط، وتعتمد المعايير التي نحتفظ بها بالبيانات على طول الفترة التي يكون فيها الحساب نشط، وطبيعة وحساسية البيانات الشخصيّة التي نجمعها، ومدة تزويدك بالخدمات، والمُتطلبات القانونيّة السارية، مثل الأوامر الحكومية لأغراض التحقيق أو التقاضي، أو الحماية من دعوى محتملة.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'c.يحتفظ تطبيق "نقلي" بالبيانات لأغراض التحليل الداخلي، أو لتعزيز الأمان، أو لتحسين وظائف التطبيق، وإنفاذ شروطنا وسياساتنا القانونية، أو لأغراض قانونية وتسويقية ومحاسبية أو لمنع الاحتيال.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "9.الإجراءات الأمنية لحماية البيانات",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        'a.نتخذ كافة التدابير الأمنية اللازمة والمناسبة لحماية البيانات الشخصيّة التي يقدمها المستخدم على تطبيق "نقلي" من الفقد، أو التلف، أو التغيير، أو الإفشاء، أو الوصول غير المسموح به، أو الاستخدام غير المقصود وغير القانوني من خلال بعض الإجراءات الوقائية التي نستخدمها مثل، جدران الحماية، وتشفير البيانات، وعناصر التحكم في الوصول المادي إلى مراكز البيانات لدينا وعناصر التحكم في إذن الوصول إلى البيانات؛ ومع ذلك، أنت تعلم أن الانترنت ليس وسيلة آمنة في جميع الأوقات، ورغم اتخاذنا لمعايير حماية عالية المستوى، إلا أنه من الممكن ألا يكون هذا المستوى من الحماية فعال بنسبة 100% إلا إذا كنت تتبع سياسات أمنية خاصة بك.',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        "b.نلتزم بالحفاظ على سرية بياناتك الشخصيّة، ونتعهد في حدود المسموح به قانونًا بعدم استخدامها أو الإفصاح عنها بما يتعارض مع هذه السياسة، ولمساعدتنا في حماية بياناتك الشخصيّة، يجب عليك دائمًا الحفاظ على أمان بيانات حسابك وعدم مشاركتها مع أيّ أحد تحت أيّ ظرف.",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                      child: Text(
                        "c.لن نقوم بتأجير أو بيع بياناتك إلى أيّ أطراف خارجية بأيّ شكل يمكن التعرّف عليك شخصياً من خلالها، ولن نسمح للغير باستخدامها لأغراض التسويق المباشر أو غير المباشر دون الحصول على موافقتك، ولكن يتم استخدام بياناتك للأغراض المعلن عنها في هذه السياسة، ويقتصر استخدامنا لهذه البيانات على الفترة اللازمة لتقديم الخدمات.",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "10.حماية بيانات الدخول للحساب",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                      child: Text(
                        "بيانات الدخول للحساب هي مسئولية شخصيّة للمستخدم، وفي حال حصول شخص آخر على تلك البيانات بأي وسيلة واستخدامها للدخول إلى التطبيق وتنفيذ أي معاملات، فإن المستخدم هو المسؤول الوحيد عن ذلك، ولا يتحمل التطبيق أدني مسئولية عما تم من عمليات.",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "11.تغييرات في بيانات الحساب",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                      child: Text(
                        "من المهم أن تكون البيانات الشخصيّة للمستخدم دقيقة ومحدّثة. يرجى إبقائنا على اطلاع بأي تغييرات تطرأ على بياناتك الشخصيّة خلال فترة تعاملك معنا.",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "12.الروابط الخارجية",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                          child: Text(
                            'a.قد يحتوي تطبيق "نقلي" على روابط تحيل المستخدم أو الزائر إلى تطبيقات أو روابط أو مواقع الكترونية خارجية والتي من شأنها أن تقوم بجمع معلومات عنك والإفصاح عنها بطريقة مختلفة عن هذا التطبيق.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                          child: Text(
                            'b.لا يتحكم تطبيق "نقلي" في ممارسات الخصوصية لأي مواقع خارجية، ولا يتحمل المسؤولية القانونية عن المحتوى المنشور على تلك المواقع، أو سياسات الخصوصية لتلك المواقع الخارجية.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                          child: Text(
                            'c.يجب على المستخدم مراجعة سياسة الخصوصية وشروط الاستخدام الخاصة بالجهات الخارجية عند زيارة أي روابط خارجية، ويوافق على أن تطبيق "نقلي" لن يكون مسؤولاً عن طريقة الجمع أو الاستخدام أو الإفصاح عن البيانات التي تتبعها أي من الأطراف الخارجية التي لديها رابط في هذا التطبيق.',
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
                          "13.مسؤوليات المستخدم",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                          child: Text(
                            "a.يلتزم المستخدم بتقديم بيانات كاملة وصحيحة ودقيقة، والالتزام بالحفاظ على سرية بيانات الحساب.",
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                          child: Text(
                            'b.يقر ويوافق المستخدم بأن تطبيق "نقلي" لا يسيطر إلا على البيانات التي يجمعها من خلاله، ولا يملك أي سيطرة على أي بيانات يقدمها المستخدم خارج التطبيق.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                          child: Text(
                            'c.لن يتحمل تطبيق "نقلي" مسؤولية فشل المستخدم في الحفاظ على خصوصيته أو سرية بياناته.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'd.يقع على المستخدم دور كبير في حماية بياناته الشخصيّة، وذلك من خلال ما يلي:',
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              '1.الاطلاع والتحكم أو تعديل المعلومات التي تحدد الهوية من خلال حسابه في التطبيق.',
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              '2.عدم الإفصاح عن بيانات حسابه لأيّ شخص آخر، وعلى الأخص بيانات الدخول للحساب.',
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                          child: Text(
                            '3.تسجيل الخروج بعد انتهاء الجلسة عند استخدام جهاز لشخص آخر أو الإنترنت في الأماكن العامة.',
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
                          "14.ملفّات تعريف الارتباط (الكوكيز)",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                          child: Text(
                            'a.يستخدم تطبيق "نقلي" خاصية الكوكيز للعمليات الأساسية مثل تصفّح التطبيق، وتقديم الإعلانات التي تناسب اهتمامات المستخدمين، بالإضافة إلى أغراض التسوق وغيرها، وبإمكانك تغيير إعدادات الكوكيز من خلال الخطوات التالية:',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 10),
                          child: Text(
                            '1.ضبط متصفّحك لإعلامك عند تلقّي واستلام ملفّات الكوكيز.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 10),
                          child: Text(
                            '2.ضبط متصفّحك لرفض أو قبول ملفّات الكوكيز.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 10),
                          child: Text(
                            '3.تصفّح التطبيق باستخدام خاصية الاستخدام المجهول للمتصفّح.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 10),
                          child: Text(
                            '4.حذف ملفّات الكوكيز بعد زبارتك للتطبيق.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 10),
                          child: Text(
                            'b.يمكنك تعطيل عمل ملفّات الكوكيز، ولكن قد يؤدي إلى منع عرض بعض صفحات التطبيق أو عرضها بشكل غير دقيق.',
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
                          "15.تعديلات سياسة الخصوصية",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                          child: Text(
                            'a.تمتلك مؤسسة بيانات الحاسب الحق الكامل في إجراء تعديلات على هذه السياسة في أي وقت لتتضمن الممارسات السائدة في تطبيق "نقلي" أو لتلبية المتطلبات القانونية، وستدخل هذه التعديلات والتوضيحات حيز التنفيذ فور نشرها على التطبيق.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 10),
                          child: Text(
                            'b.إذا قمنا بإجراء تغييرات جوهرية على هذه السياسة، سنقوم بإعلامك -إذا كان ممكناً- بأنه قد تم تحديثها، وسيتم نشر هذه التعديلات على هذه الصفحة وتحديث تاريخ السريان المذكور أعلاه، حتى تكون على دراية بالمعلومات التي نجمعها، وكيفية استخدامها، وتحت أي ظروف، إن وجدت، سنقوم باستخدامها أو الكشف عنها.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 10),
                          child: Text(
                            'c.ننصح جميع المستخدمين بمراجعة وقراءة هذه السياسة بشكل منتظم للاطلاع على تعديلاتها، يرجى العلم بأننا لن نتحمل مسؤولية عدم مراجعتك هذه السياسة قبل استخدام التطبيق، وأن قراءة هذه السياسة من قبل مستخدمي تطبيق "نقلي" هو إقرار كامل واعتراف منهم بكل ما ورد بهذه السياسة وموافقة على جميع ما ورد فيها.',
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
                          "16.الموافقة على سياسة الخصوصية",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                          child: Text(
                            'a.يقر المستخدم بأنه قرأ سياسة الخصوصية هذه، ويوافق على الالتزام بجميع بنودها وشروطها.',
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 8, 8, 10),
                          child: Text(
                            'b.يوافق المستخدم بأن استخدامه لتطبيق "نقلي" أو خدماته يشير إلى موافقة صريحة على هذه السياسة والشروط التي تحكم استخدام هذا التطبيق.',
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
                          "17.الأسئلة والتعليقات",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                      ['1.1. This Privacy Policy ("Policy") constitutes a binding and enforceable legal contract between you ("the User") and Computer Data Corporation (the owner, operator, controller, and administrator of the Naqlee App Privacy Policy). Please read it carefully before using the App.',
                      '1.2. We respect the privacy of all users and are committed to protecting their personal data. Therefore, we have prepared this Policy to help you understand the procedures and practices followed by Computer Data Corporation when collecting, using, and sharing personal data, and how this data is secured and handled when you visit and use the Naqlee App.']
                  ),
                  privacyPolicy('2.Policy Acceptance', [
                    '2.1. By accessing or using the Naqlee App, you acknowledge that you have read this Policy and the Terms of Use ("Terms and Conditions") and expressly agree to be bound by all of the terms contained therein.',
                    '2.2. By using the Naqlee App or placing orders through it, you expressly consent to the collection, use, processing, and storage of your personal data in accordance with this Policy, allow us to contact you with information about services and products that may be of interest to you, and consent to any changes we make to this Privacy Policy in the future. If you do not agree to the practices described in this Policy, you may not use this App.',
                  ]),
                  privacyPolicy('3.Scope of Policy', [
                    '3.1. This Policy applies to everyone who visits, browses, or uses the Naqlee App, including the information, data, services, tools, and all other pages and activities we provide on or through the App.',
                    '3.2. This Policy does not apply to any other third-party websites, applications, or services linked to the Naqlee App, nor does it apply to information provided or collected through websites maintained by other companies or organizations.',
                  ]),
                  privacyPolicy('4.General Privacy Principles', [
                    "The Computer Data Foundation has established important principles related to users' personal data, which are:",
                    '4.1. Publish and update this Policy, as necessary, to clarify the practices followed when using the Naqlee App.',
                    '4.2. Collect and use personal data in accordance with the purposes specified in this Policy.',
                    '4.3. Process personal data in accordance with the purposes for which it is collected, used, and shared.',
                    '4.4. Take reasonable steps to ensure that personal information is reliable, accurate, complete, and up-to-date.',
                    '4.5. Take appropriate measures to provide adequate protection for data disclosed to third parties.',
                  ]),
                  privacyPolicy('5.Data Collection Methods', [
                    'The Naqlee App collects personal data from users in various ways, as follows:',
                  ]),
                  privacyPolicy('5.1 Direct Interactions', [
                    '5.1.1. Account Data: When registering for an account with the Naqlee App, the user provides us with specific data, including: name, email address, mobile number, and any additional data requested by the App administration.',
                    '5.1.2. Contact Data: When communicating with us through the methods available in the App, or responding to email messages, such as username, email address, message subject, and subject.',
                    "5.1.3. Order Data: When placing an order for a product through the Naqlee App, we collect order data such as the recipient's name, type, quantity, total order amount, phone number, shipping and billing address, and any other data we deem necessary or required by applicable laws and regulations.",
                    '5.1.4. Payment Data: When paying for orders, the customer must pay through one of the methods available on the application. Payment data is provided to the contracted payment service providers to process the payment.',
                    '5.1.5. Subscription Data: When subscribing to newsletters or completing any other forms provided by the application.',
                    '5.1.6. Post Data: When adding comments, opinions, or feedback.',
                  ]),
                  privacyPolicy('5.2 Automated Interactions', [
                    '5.2.1. Technical Data: This includes the IP address connecting your device to the Internet, browser type, referring/exit pages, Internet service provider, device identifiers, advertising ID, operating system, add-on types, date and time of access, number of clicks, information about the use of our services, and data related to devices connected to the network.',
                    '5.2.2. Log Data: This includes device log data, internal usage analytics tools, products you viewed or searched for, page response times, length of visits to certain pages, page interaction information, geolocation data, and any phone number used to contact our customer service number.',
                    '5.2.3. Approximate Geographic Data: Such as country, city, and geographic coordinates, calculated based on your IP address or geolocation by the customer.',
                    '5.2.4. Tracking Technology Data: This includes cookies, tracking pixels, and web beacons used to collect and store your relevant personal data.',
                  ]),
                  privacyPolicy('5.3 Third Parties', [
                    '5.3.1. Data from Partners: Such as marketing and advertising partners and other third parties.',
                    '5.3.2. Data from Social Networks: Such as Facebook, Twitter, and others.',
                  ]),
                  privacyPolicy('6. Purposes of Data Use', [
                    'The Naqlee App uses the data it collects for the following purposes:',
                    '6.1. Assisting the user in creating an account, verifying identity, and logging into the account.',
                    '6.2. Promoting our business, including improving the content and functionality of the App, and providing better customer service.',
                    '6.3. Providing the user with technical support, responding to questions, inquiries, and emails.',
                    '6.4. Sending administrative messages related to the Service and informing, alerting, and providing information about Privacy Policy updates, account confirmations, security updates, tips, or other relevant information.',
                    '6.5. Providing the user with suggestions and recommendations regarding services and products of interest based on their activity on the App.',
                    '6.6. Improving the Services, including by personalizing the user experience.',
                    '6.7. Preventing prohibited or illegal activities, complying with applicable laws, enforcing our Terms, and any other purposes disclosed to you at the time we collect your information or pursuant to your consent.',
                    '6.8. Conducting market research and surveys, and for statistical, research, analytical, and promotional purposes.',
                  ]),
                  privacyPolicy('7. Data Sharing', [
                    '7.1. We share the personal data we collect in accordance with this Policy with our affiliates and other third parties to fulfill the purposes set out in Section [6] of this Policy. Accordingly, we may share data in the following circumstances:',
                    '7.1.1. With your consent: We may share your data if you have given us specific consent to use your personal data for a specific purpose.',
                    '7.1.2. Legitimate interests: We may share your data when it is necessary to fulfill our legitimate interests.',
                    '7.1.3. Performance of a contract: We may share your personal data to fulfill the terms of our contract with you.',
                    '7.1.4. Legal Obligations: We may share your data when required to do so by a court order, or when we are under a duty to disclose or share your data in order to comply with any legal obligation.',
                    '7.1.5. Vital Interests: We may share your data when we believe it is necessary to investigate, prevent, or take action regarding potential violations of our policies, suspected fraud, situations involving potential threats to the safety of any person and illegal activities, or as evidence in litigation in which we are involved.',
                    '7.1.6. Truck Owners: When you submit a job application to those registered on the "Naqlee" application, we share certain user data with the service requester to facilitate the process of fulfilling the application.',
                    '7.1.7. Payment Processing: When making a payment for orders through the Naqlee App, the user may be asked to provide specific electronic payment details to complete the payment process. The user expressly agrees that we may share their data with payment processors to facilitate the payment process (including, but not limited to, fraud detection service providers).',
                    '7.1.8. Marketing and Promotional Offers: We may share data with entities that assist us in marketing, promoting our services, continuously developing, and enhancing the user experience on the App.',
                    '7.1.9. Business Transfer: In the event of any transfer or change in the business of Computer Data Corporation, we may share data with a third party in connection with any merger, acquisition, reorganization, asset sale, joint venture, assignment, transfer, or similar disposition of all or a portion of our business or assets. During negotiations, your data may be sold or transferred as part of that transaction, and the new entity may use the data in the same manner as set forth in this Policy.',
                    '7.2. You grant us the right to allow our employees and business partners to process your personal data within the scope of providing the Services. Please note that any third parties\' use of your data will be subject to their own privacy policies; we recommend that you carefully review the privacy policies of these third parties.',
                  ]),
                  privacyPolicy('8. Data Storage and Retention', [
                    '8.1. The Naqlee App stores users\' personal data for as long as necessary to fulfill the purposes specified in Section [6]. We may retain it to review the current Privacy Policy, or when applicable laws occasionally require us to retain that data for a longer period of time for compliance with the laws to which we are subject or to defend claims against us.',
                    '8.2. The Naqlee App retains account-related data in electronic records for as long as you have an active account. The criteria for retaining data depend on the length of time your account is active, the nature and sensitivity of the personal data we collect, the duration of your provision of the Services, and applicable legal requirements, such as government orders for investigation or litigation purposes, or to protect against potential claims.',
                    '8.3. The Naqlee App retains data for internal analysis purposes, to enhance security, to improve the functionality of the App, to enforce our terms and legal policies, or for legal, marketing, and accounting purposes, or to prevent fraud.',
                  ]),
                  privacyPolicy('9. Data Security Measures', [
                    '9.1. We take all necessary and appropriate security measures to protect the personal data provided by the user on the Naqlee App from loss, damage, alteration, disclosure, unauthorized access, or unintended and unlawful use. We employ certain preventative measures, such as firewalls, data encryption, physical access controls to our data centers, and data access permission controls. However, you know that the internet is not always secure, and while we maintain high security standards, this level of protection may not be 100% effective unless you follow your own security policies.',
                    '9.2. We are committed to maintaining the confidentiality of your personal data and, to the extent permitted by law, we pledge not to use or disclose it in a manner inconsistent with this Policy. To help us protect your personal data, you must always keep your account data secure and not share it with anyone under any circumstances.',
                    '9.3. We will not rent or sell your data to any third parties in any way that could identify you personally, and we will not allow third parties to use it for direct or indirect marketing purposes without obtaining your consent. However, your data will be used for the purposes stated in this policy, and our use of this data will be limited to the period necessary to provide the services.',
                  ]),
                  privacyPolicy('10. Account Login Data Protection', [
                    'Account login data is the user\'s personal responsibility. If someone else obtains such data by any means and uses it to access the application and perform any transactions, the user is solely responsible for this, and the application bears no liability for any such transactions.',
                  ]),
                  privacyPolicy('11. Changes to Account Data', [
                    'It is important that the user\'s personal data is accurate and up-to-date. Please keep us informed of any changes to your personal data during your relationship with us.',
                  ]),
                  privacyPolicy('12. External Links', [
                    '12.1. The Naqlee App may contain links that direct the user or visitor to external applications, links, or websites that may collect and disclose information about you in a manner different from that of this App.',
                    '12.2. The Naqlee App does not control the privacy practices of any external websites and is not legally responsible for the content posted on those websites or the privacy policies of those external websites.',
                    '12.3. The User should review the privacy policy and terms of use of third parties when visiting any external links, and agrees that the Naqlee App will not be responsible for the collection, use, or disclosure of data tracked by any third party linked to this App.',
                  ]),
                  privacyPolicy('13. User Responsibilities', [
                    '13.1. The User is obligated to provide complete, true, and accurate data and to maintain the confidentiality of account information.',
                    '13.2. The User acknowledges and agrees that the Naqlee App only controls the data it collects through it and has no control over any data the User provides outside the App.',
                    '13.3. The Naqlee App will not be liable for the User\'s failure to maintain the privacy or confidentiality of their data.',
                    '13.4. The User has a significant role in protecting their personal data, through the following:',
                    '13.4.1. Accessing, controlling, or modifying identifying information through their App account.',
                    '13.4.2. Not to disclose your account information, particularly your account login information, to any other person.',
                    '13.4.3. Log out after your session ends when using someone else\'s device or the internet in public places.',
                  ]),
                  privacyPolicy('14. Cookies', [
                    '14.1. The Naqlee App uses cookies for basic operations such as browsing the App, serving ads tailored to users\' interests, shopping, and other purposes. You can change your cookie settings by following these steps:',
                    '14.1.1. Set your browser to notify you when you receive cookies.',
                    '14.1.2. Set your browser to accept or reject cookies.',
                    '14.1.3. Browse the App using your browser\'s anonymous browsing feature.',
                    '14.1.4. Delete cookies after visiting the App.',
                    '14.2. You can disable cookies, but this may prevent or inaccurately display some App pages.',
                  ]),
                  privacyPolicy('15. Privacy Policy Changes', [
                    '15.1. Computer Data Corporation reserves the right to make changes to this policy at any time to reflect prevailing practices within the Naqlee App or to meet legal requirements. Such changes and clarifications will take effect immediately upon posting on the App.',
                    '15.2. If we make material changes to this Policy, we will notify you, if applicable, that it has been updated. These changes will be posted on this page and the effective date above will be updated so that you are aware of what information we collect, how we use it, and under what circumstances, if any, we use or disclose it.',
                    '15.3. We advise all users to review and read this Policy regularly for changes. Please note that we are not responsible for your failure to review this Policy before using the App. By reading this Policy, users of the Naqlee App fully acknowledge and agree to all of its contents.',
                  ]),
                  privacyPolicy('16. Acceptance of the Privacy Policy', [
                    '16.1. The User acknowledges that he/she has read this Privacy Policy and agrees to abide by all of its terms and conditions.',
                    '16.2. The User agrees that his/her use of the Naqlee App or its services indicates explicit acceptance of this Policy and the terms governing the use of this App.',
                  ]),
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
                        'Copyright © Naqlee 2024',
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

      if (matchedWord == null) {
        spans.add(TextSpan(text: remainingText));
        break;
      }
      if (firstMatchIndex > 0) {
        spans.add(TextSpan(text: remainingText.substring(0, firstMatchIndex)));
      }
      spans.add(TextSpan(text: matchedWord, style: TextStyle(fontWeight: FontWeight.bold)));

      remainingText = remainingText.substring(firstMatchIndex + matchedWord.length);

      if (remainingText == text) {
        break;
      }
    }

    return Text.rich(TextSpan(children: spans));
  }

}
