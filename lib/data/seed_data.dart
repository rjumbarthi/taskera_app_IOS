// ignore_for_file: lines_longer_than_80_chars
import 'package:drift/drift.dart';
import 'database.dart';


// Maps AppStrings 19-lang index → 19-lang seed index
// Seed order: 0=en,1=ja,2=de,3=ko,4=fr,5=zh,6=es,7=pt,8=hi,9=ar,10=te,
//             11=it,12=nl,13=ta,14=kn,15=ml,16=mr,17=gu,18=bn
int _seedLang(int appLang) {
  const map = <int>[0, 1, 2, 3, 4, 5, 6, 7, 11, 12, 9, 8, 10, 13, 14, 15, 16, 17, 18];
  //               en ja de ko fr zh es pt  it  nl ar hi  te  ta  kn  ml  mr  gu  bn
  return map[appLang < map.length ? appLang : 0];
}

String _s(List<String> opts, int lang) =>
    opts[lang < opts.length ? lang : 0];

Future<void> seedDatabase(AppDatabase db, {int langIdx = 0}) async {
  final count = await db.select(db.tasks).get();
  if (count.isNotEmpty) return; // already seeded
  final lang = _seedLang(langIdx);
  await _seedTasks(db, lang);
  await _seedHabits(db, lang);
  await _seedGoals(db, lang);
  await _seedNotes(db, lang);
  await _seedCalendar(db, lang);
}

/// Wipes all seeded content and re-seeds in [langIdx].
/// Called when the user switches language so stored text matches the UI.
Future<void> reseedDatabase(AppDatabase db, {int langIdx = 0}) async {
  // Delete children first to respect FK ordering
  await db.delete(db.subtasks).go();
  await db.delete(db.tasks).go();
  await db.delete(db.subHabits).go();
  await db.delete(db.habitLogs).go();
  await db.delete(db.habits).go();
  await db.delete(db.goalTaskLinks).go();
  await db.delete(db.goalHabitLinks).go();
  await db.delete(db.goals).go();
  await db.delete(db.noteTags).go();
  await db.delete(db.notes).go();
  await db.delete(db.calendarEvents).go();
  final lang = _seedLang(langIdx);
  await _seedTasks(db, lang);
  await _seedHabits(db, lang);
  await _seedGoals(db, lang);
  await _seedNotes(db, lang);
  await _seedCalendar(db, lang);
}

// ── Tasks ─────────────────────────────────────────────────────────────────────

Future<void> _seedTasks(AppDatabase db, int lang) async {
  final now      = DateTime.now();
  final today    = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));

  // Q1 — Urgent & Important
  final q1Titles = [
    _s(['Submit assignment before deadline','締め切り前に課題を提出','Aufgabe vor Deadline einreichen','마감 전 과제 제출','Soumettre le devoir avant la date limite','截止前提交作业','Entregar tarea antes del plazo','Entregar tarefa antes do prazo','समय सीमा से पहले असाइनमेंट जमा करें','تسليم المهمة قبل الموعد النهائي','గడువుకు ముందు అసైన్‌మెంట్ సమర్పించండి','Consegna compito prima della scadenza','Opdracht inleveren vóór deadline','காலக்கெடுவிற்கு முன் பணி சமர்ப்பிக்கவும்','ಗಡುವಿಗೆ ಮೊದಲು ಕಾರ್ಯ ಸಲ್ಲಿಸಿ','സമയപരിധിക്ക് മുൻപ് അസൈൻ‌മെൻ്റ് സമർ‌പ്പിക്കുക','मुदतीपूर्वी असाइनमेंट सादर करा','આKhri tarikha paheLaa kaarya jama karo','সময়সীমার আগে অ্যাসাইনমেন্ট জমা দিন'], lang),
    _s(['Fix gym app bug #482','ジムアプリのバグ#482修正','Gym-App Bug #482 beheben','헬스 앱 버그 #482 수정','Corriger le bug app gym #482','修复健身应用错误#482','Corregir bug app gym #482','Corrigir bug app academia #482','जिम ऐप बग #482 ठीक करें','إصلاح خطأ تطبيق الصالة #482','జిమ్ యాప్ బగ్ #482 పరిష్కరించండి','Correggi bug app palestra #482','Gym-app bug #482 oplossen','ஜிம் ஆப் பிழை #482 சரிசெய்யவும்','ಜಿಮ್ ಆ್ಯಪ್ ದೋಷ #482 ಸರಿಪಡಿಸಿ','ജിം ആപ്പ് ബഗ് #482 പരിഹരിക്കുക','जिम अॅप बग #482 दुरुस्त करा','જિમ એપ બગ #482 ઠીક કરો','জিম অ্যাপ বাগ #482 ঠিক করুন'], lang),
    _s(['Submit tax return before deadline','締め切り前に確定申告を提出','Steuererklärung vor Deadline','세금 신고 마감 전 제출','Déclaration fiscale avant deadline','截止前提交纳税申报','Declaración de impuestos a tiempo','Declaração de imposto antes do prazo','समय सीमा से पहले टैक्स रिटर्न जमा करें','تقديم الإقرار الضريبي قبل الموعد','గడువుకు ముందు పన్ను రిటర్న్ సమర్పించండి','Presentare la dichiarazione fiscale in tempo','Belastingaangifte voor deadline indienen','காலக்கெடுவிற்கு முன் வரி கணக்கு சமர்ப்பிக்கவும்','ಗಡುವಿಗೆ ಮೊದಲು ತೆರಿಗೆ ರಿಟರ್ನ್ ಸಲ್ಲಿಸಿ','സമയപരിധിക്ക് മുൻപ് നികുതി റിട്ടേൺ സമർ‌പ്പിക്കുക','मुदतीपूर्वी कर परतावा सादर करा','સmay paheLaa tax return jama karo','সময়সীমার আগে কর রিটার্ন জমা দিন'], lang),
    _s(['Call client about urgent contract','緊急契約でクライアントに電話','Kunden wegen Vertrag anrufen','긴급 계약 고객에게 전화','Appeler client pour contrat urgent','就紧急合同联系客户','Llamar al cliente por contrato urgente','Ligar para cliente sobre contrato urgente','अर्जेंट कॉन्ट्रैक्ट के लिए क्लाइंट को कॉल करें','الاتصال بالعميل بشأن العقد العاجل','అత్యవసర కాంట్రాక్ట్ కోసం క్లయింట్‌కు కాల్ చేయండి','Chiamare il cliente per il contratto urgente','Klant bellen over urgent contract','அவசர ஒப்பந்தம் பற்றி வாடிக்கையாளரை அழைக்கவும்','ತುರ್ತು ಒಪ್ಪಂದದ ಬಗ್ಗೆ ಗ್ರಾಹಕರಿಗೆ ಕರೆ ಮಾಡಿ','അടിയന്തര കരാറിനെ കുറിച്ച് ക്ലയൻ്റിനെ വിളിക്കുക','तातडीच्या कराराबद्दल ग्राहकाला कॉल करा','tatkal karar maate client ne call karo','জরুরি চুক্তি সম্পর্কে ক্লায়েন্টকে কল করুন'], lang),
    _s(['Reply to investor email','投資家メールに返信','Investoren-E-Mail beantworten','투자자 이메일 답장','Répondre à l\'email investisseur','回复投资者邮件','Responder correo del inversor','Responder e-mail do investidor','निवेशक ईमेल का जवाब दें','الرد على بريد المستثمر','పెట్టుబడిదారు ఇమెయిల్‌కు జవాబు ఇవ్వండి','Rispondere all\'email dell\'investitore','Reageren op e-mail van investeerder','முதலீட்டாளர் மின்னஞ்சலுக்கு பதிலளிக்கவும்','ಹೂಡಿಕೆದಾರರ ಇಮೇಲ್‌ಗೆ ಪ್ರತ್ಯುತ್ತರಿಸಿ','നിക്ഷേ‌പകൻ്റെ ഇമെ‌യിലിന് മറുപടി നൽകുക','गुंतवणूकदाराच्या ईमेलला उत्तर द्या','ramrokaN karta ne email no javab apo','বিনিয়োগকারীর ইমেইলের উত্তর দিন'], lang),
    _s(['Renew passport — expires Friday','パスポート更新 — 金曜日期限','Reisepass verlängern — Freitag','여권 갱신 — 금요일 만료','Renouveler passeport — expire vendredi','护照续签 — 周五到期','Renovar pasaporte — vence viernes','Renovar passaporte — vence sexta','पासपोर्ट नवीनीकरण — शुक्रवार को समाप्त','تجديد جواز السفر — ينتهي الجمعة','పాస్‌పోర్ట్ నవీకరించండి — శుక్రవారం గడువు','Rinnovare il passaporto — scade venerdì','Paspoort verlengen — verloopt vrijdag','பாஸ்போர்ட்டை புதுப்பிக்கவும் — வெள்ளி காலாவதி','ಪಾಸ್‌ಪೋರ್ಟ್ ನವೀಕರಿಸಿ — ಶುಕ್ರವಾರ ಮುಕ್ತಾಯ','പാ‌സ്‌പോർ‌ട്ട് പുതുക്കുക — വെ‌ള്ളി‌യാ‌ഴ്ച കാ‌ലഹ‌ര‌ണ‌പ്പെ‌ടും','पासपोर्ट नूतनीकरण करा — शुक्रवारी मुदत संपते','passport navikaran karo — shukrawar e samaapt','পাসপোর্ট নবায়ন করুন — শুক্রবার মেয়াদ শেষ'], lang),
    _s(['Hospital prescription refill','病院の処方箋補充','Krankenhausrezept auffüllen','병원 처방전 리필','Renouveler ordonnance à l\'hôpital','医院处方续药','Renovar receta del hospital','Renovar receita do hospital','अस्पताल का प्रिस्क्रिप्शन रिफिल','تجديد وصفة المستشفى','ఆసుపత్రి ప్రిస్క్రిప్షన్ రీఫిల్','Rinnovo della prescrizione ospedaliera','Ziekenhuisrecept herbestellen','மருத்துவமனை மருந்துச்சீட்டு மறுநிரப்பல்','ಆಸ್ಪತ್ರೆ ಪ್ರಿಸ್ಕ್ರಿಪ್ಷನ್ ರಿಫಿಲ್','ആ‌ശുപ‌ത്രി പ്ര‌സ്‌ക്രി‌പ്ഷൻ റീ‌ഫിൽ','रुग्णालयाचे प्रिस्क्रिप्शन रीफिल','hospital prescription refill karo','হাসপাতালের প্রেসক্রিপশন রিফিল করুন'], lang),
    _s(['Fix production outage ticket','本番環境障害チケット修正','Produktionsausfall-Ticket beheben','프로덕션 장애 티켓 해결','Résoudre ticket panne production','修复生产故障工单','Resolver ticket de interrupción','Resolver ticket de falha','प्रोडक्शन आउटेज टिकट ठीक करें','إصلاح تذكرة انقطاع الإنتاج','ప్రొడక్షన్ అంతరాయ టికెట్ పరిష్కరించండి','Risolvere il ticket di interruzione produzione','Productie-uitvalticket oplossen','உற்பத்தி தடை டிக்கெட்டை சரிசெய்யவும்','ಉತ್ಪಾದನಾ ಅಡಚಣೆ ಟಿಕೆಟ್ ಸರಿಪಡಿಸಿ','പ്ര‌ൊഡ‌ക്ഷൻ ഔ‌ട്ടേ‌ജ് ടി‌ക്ക‌റ്റ് പ‌രി‌ഹ‌രി‌ക്കുക','प्रोडक्शन आउटेज तिकीट दुरुस्त करा','production outage ticket thik karo','প্রোডাকশন আউটেজ টিকিট ঠিক করুন'], lang),
    _s(['Pay rent before late fee','遅延手数料前に家賃支払','Miete vor Mahngebühr bezahlen','연체료 전에 임대료 납부','Payer loyer avant pénalités','在滞纳金前缴纳房租','Pagar alquiler antes de mora','Pagar aluguel antes da multa','लेट फी से पहले किराया चुकाएं','دفع الإيجار قبل رسوم التأخير','జరిమానాకు ముందు అద్దె చెల్లించండి','Pagare l\'affitto prima della mora','Huur betalen vóór boete','தாமதக் கட்டணத்திற்கு முன் வாடகை செலுத்துங்கள்','ತಡ ಶುಲ್ಕಕ್ಕೆ ಮೊದಲು ಬಾಡಿಗೆ ಪಾವತಿಸಿ','ലേ‌ററ്‌ ഫീ‌ ഈ‌ടാ‌ക്കു‌ന്ന‌തിന് മുൻ‌പ് വാ‌ടക അ‌ട‌യ്ക്കുക','विलंब शुल्कापूर्वी भाडे भरा','moDeL charge paheLaa bhaaDu bharvo','বিলম্ব ফির আগে ভাড়া দিন'], lang),
    _s(['Reschedule cancelled flight','キャンセルフライト再予約','Stornierten Flug umbuchen','취소된 항공편 재예약','Reporter le vol annulé','重新安排取消的航班','Reprogramar vuelo cancelado','Remarcar voo cancelado','रद्द फ्लाइट पुनः शेड्यूल करें','إعادة جدولة الرحلة الملغاة','రద్దు చేసిన విమానం పున:నిర్ణయించండి','Riprogrammare il volo cancellato','Geannuleerde vlucht herplannen','ரத்தான விமானத்தை மறுதிட்டமிடவும்','ರದ್ದಾದ ವಿಮಾನವನ್ನು ಮರು-ನಿಗದಿ ಮಾಡಿ','ര‌ദ്ദാ‌ക്കി‌യ ഫ്ലൈ‌റ്റ് പു‌ന‌ഃ‌ക്ര‌മീ‌ക‌രി‌ക്കുക','रद्द झालेल्या उड्डाणाचे पुनर्नियोजन करा','radd thayelI flight ne farthi schedule karo','বাতিল ফ্লাইট পুনরায় নির্ধারণ করুন'], lang),
  ];
  final q1Labels = [
    'Today · Overdue · Score 9.2', 'Today · Score 7.8',
    'Today · Overdue · Score 9.0', 'Today · Overdue · Score 8.7',
    'Today · Score 8.5', 'Tomorrow · Score 8.3',
    'Today · Overdue · Score 8.0', 'Today · Score 7.5',
    'Tomorrow · Score 7.2', 'Today · Score 7.0',
  ];
  final q1Due    = [today, today, today, today, today, tomorrow, today, today, tomorrow, today];
  // Minute-of-day for each task so the Today's Plan agenda has real times.
  final q1Mins   = [480, 570, 660, 780, 870, 600, 930, 960, 840, 1020];
  final q1Over   = [true, false, true, true, false, false, true, false, false, false];
  final q1Score  = [9.2, 7.8, 9.0, 8.7, 8.5, 8.3, 8.0, 7.5, 7.2, 7.0];

  for (var i = 0; i < q1Titles.length; i++) {
    final id = await db.tasksDao.insertTask(TasksCompanion(
      title:            Value(q1Titles[i]),
      quadrant:         const Value(1),
      dueDate:          Value(q1Due[i].add(Duration(minutes: q1Mins[i]))),
      dueLabel:         Value(q1Labels[i]),
      isOverdue:        Value(q1Over[i]),
      hasAi:            const Value(false),
      urgencyScore:     Value(q1Score[i]),
      recurrenceLabel:  const Value(null),
      hasPomodoro:      const Value(false),
      sortOrder:        Value(i),
    ));
    if (i == 0) {
      final subs = [
        (_s(['Executive summary','エグゼクティブサマリー','Zusammenfassung','요약문','Résumé exécutif','执行摘要','Resumen ejecutivo','Resumo executivo','कार्यकारी सारांश','الملخص التنفيذي','కార్యనిర్వాహక సారాంశం','Sintesi esecutiva','Managementsamenvatting','நிர்வாக சுருக்கம்','ಕಾರ್ಯನಿರ್ವಾಹಕ ಸಾರಾಂಶ','എ‌ക്സി‌ക്യൂ‌ട്ടീ‌വ് സ‌മ്മ‌റി','कार्यकारी सारांश','executive summary','নির্বাহী সারসংক্ষেপ'], lang), true),
        (_s(['Financial projections','財務予測','Finanzprognosen','재무 예측','Prévisions financières','财务预测','Proyecciones financieras','Projeções financeiras','वित्तीय अनुमान','التوقعات المالية','ఆర్థిక అంచనాలు','Previsioni finanziarie','Financiële prognoses','நிதி கணிப்புகள்','ಹಣಕಾಸು ಮುನ್ನಂದಾಜು','സാ‌മ്പ‌ത്തി‌ക പ്ര‌ൊ‌ജ‌ക്ഷ‌നു‌കൾ','आर्थिक अंदाज','naaNaakiy anuman','আর্থিক অনুমান'], lang), false),
        (_s(['Q&A prep','Q&A準備','Q&A-Vorbereitung','Q&A 준비','Préparation Q&R','Q&A准备','Preparación de Q&A','Preparação de Q&A','Q&A तैयारी','إعداد جلسة الأسئلة والأجوبة','Q&A సన్నద్ధత','Preparazione Q&A','Q&A voorbereiding','கேள்வி-பதில் தயாரிப்பு','Q&A ತಯಾರಿ','Q&A ത‌യ്യാ‌റെ‌ടു‌പ്പ്','प्रश्नोत्तर तयारी','Q&A taiyari','প্রশ্নোত্তর প্রস্তুতি'], lang), false),
      ];
      for (var j = 0; j < subs.length; j++) {
        await db.tasksDao.insertSubtask(SubtasksCompanion(
          taskId: Value(id), title: Value(subs[j].$1),
          isDone: Value(subs[j].$2), sortOrder: Value(j),
        ));
      }
    }
  }

  // Q2 — Not Urgent, Important
  final q2Titles = [
    _s(['Study for exam — Chapter 4','試験勉強 — 第4章','Prüfung lernen — Kapitel 4','시험 공부 — 4장','Réviser pour examen — Chap. 4','备考 — 第4章','Estudiar para examen — Cap. 4','Estudar para prova — Cap. 4','परीक्षा की तैयारी — अध्याय 4','الدراسة للامتحان — الفصل 4','పరీక్షకు చదువు — అధ్యాయం 4','Studiare per esame — Capitolo 4','Studeren voor examen — Hoofdstuk 4','தேர்வுக்கு படிக்கவும் — அத்தியாயம் 4','ಪರೀಕ್ಷೆಗೆ ಅಧ್ಯಯನ — ಅಧ್ಯಾಯ 4','പ‌രീ‌ക്ഷ‌യ്ക്ക് പ‌ഠി‌ക്കുക — അ‌ദ്ധ്യ‌ായം 4','परीक्षेसाठी अभ्यास — अध्याय 4','exam maate abhyas — chapter 4','পরীক্ষার জন্য পড়াশোনা — অধ্যায় 4'], lang),
    _s(['Morning journaling','朝のジャーナリング','Morgentagebuch','아침 저널링','Journal du matin','晨间日记','Diario matutino','Diário matinal','सुबह जर्नलिंग','التأمل الصباحي','ఉదయం జర్నలింగ్','Diario mattutino','Ochtenddagboek','காலை குறிப்பேடு','ಬೆಳಿಗ್ಗೆ ಜರ್ನಲಿಂಗ್','ര‌ാ‌വി‌ലെ ജേ‌ർ‌ണ‌ലിം‌ഗ്','सकाळचे लेखन','savare ni diary','সকালের জার্নালিং'], lang),
    _s(['Pay gym membership fees','ジム会費を支払う','Fitnessstudio-Mitgliedschaft bezahlen','헬스장 회비 납부','Payer cotisation du gym','缴纳健身房会员费','Pagar cuota del gimnasio','Pagar mensalidade da academia','जिम की सदस्यता फीस चुकाएं','دفع رسوم عضوية الصالة','జిమ్ సభ్యత్వ రుసుము చెల్లించండి','Pagare la quota del palestra','Sportschoollidmaatschap betalen','உடற்பயிற்சி கட்டண பணம் செலுத்துங்கள்','ಜಿಮ್ ಸದಸ್ಯತ್ವ ಶುಲ್ಕ ಪಾವತಿಸಿ','ജിം അം‌ഗ‌ത്വ ഫീ അ‌ട‌യ്ക്കുക','जिम सदस्यत्व शुल्क भरा','gym ni fee bharvo','জিম সদস্যপদ ফি দিন'], lang),
    _s(['Plan next quarter roadmap','次四半期ロードマップ計画','Nächste-Quartal-Roadmap planen','다음 분기 로드맵 계획','Planifier roadmap prochain trimestre','规划下季度路线图','Planificar roadmap próximo trimestre','Planejar roadmap próximo trimestre','अगली तिमाही का रोडमैप प्लान करें','تخطيط خارطة طريق الربع القادم','తదుపరి త్రైమాసిక రోడ్‌మ్యాప్ ప్లాన్ చేయండి','Pianificare la roadmap del prossimo trimestre','Roadmap volgend kwartaal plannen','அடுத்த காலாண்டு திட்டம் வரையவும்','ಮುಂದಿನ ತ್ರೈಮಾಸಿಕ ರೋಡ್‌ಮ್ಯಾಪ್ ಯೋಜಿಸಿ','അ‌ടു‌ത്ത ക്വ‌ാർ‌ട്ടർ ആ‌സൂ‌ത്ര‌ണം','पुढील तिमाही रोडमॅप तयार करा','aagaLa quarter no roadmap banavo','পরের ত্রৈমাসিকের রোডম্যাপ পরিকল্পনা করুন'], lang),
    _s(['Write blog post on focus','フォーカスについてブログ投稿','Blogpost über Fokus schreiben','집중에 관한 블로그 작성','Écrire article de blog sur focus','写关于专注的博客','Escribir artículo blog sobre enfoque','Escrever post blog sobre foco','फोकस पर ब्लॉग पोस्ट लिखें','كتابة مقال مدونة عن التركيز','ఫోకస్ పై బ్లాగ్ పోస్ట్ రాయండి','Scrivere un articolo blog sul focus','Blogpost over focus schrijven','கவனத்தில் வலைப்பதிவு எழுதவும்','ಫೋಕಸ್ ಬಗ್ಗೆ ಬ್ಲಾಗ್ ಪೋಸ್ಟ್ ಬರೆಯಿರಿ','ഫോ‌ക്ക‌സ് ഒ‌രു ബ്ലോ‌ഗ് പോ‌സ്റ്റ് എ‌ഴु‌തുക','फोकसवर ब्लॉग पोस्ट लिहा','focus par blog post lakho','ফোকাস বিষয়ে ব্লগ পোস্ট লিখুন'], lang),
    _s(['Annual health checkup','年次健康診断','Jährliche Gesundheitsuntersuchung','연간 건강 검진','Bilan de santé annuel','年度健康检查','Chequeo médico anual','Exame médico anual','वार्षिक स्वास्थ्य जांच','الفحص الصحي السنوي','వార్షిక ఆరోగ్య తనిఖీ','Visita medica annuale','Jaarlijkse gezondheidscheck','ஆண்டு உடல் பரிசோதனை','ವಾರ್ಷಿಕ ಆರೋಗ್ಯ ತಪಾಸಣೆ','വ‌ാർ‌ഷി‌ക ആ‌രോ‌ഗ്യ പ‌രി‌ശോ‌ധ‌ന','वार्षिक आरोग्य तपासणी','varshik svasthya tapaas','বার্ষিক স্বাস্থ্য পরীক্ষা'], lang),
    _s(['Strategic planning session','戦略立案セッション','Strategieplanung-Sitzung','전략 계획 세션','Session de planification stratégique','战略规划会议','Sesión de planificación estratégica','Sessão de planejamento estratégico','स्ट्रैटेजिक प्लानिंग सेशन','جلسة التخطيط الاستراتيجي','వ్యూహాత్మక ప్రణాళిక సమావేశం','Sessione di pianificazione strategica','Strategische planningssessie','மூலோபாய திட்டமிடல் கூட்டம்','ಕಾರ್ಯತಂತ್ರ ಯೋಜನೆ ಅಧಿವೇಶನ','ത‌ന്ത്ര‌പ്ര‌ധാ‌ന ആ‌സൂ‌ത്ര‌ണ സെ‌ഷൻ','धोरणात्मक नियोजन सत्र','vEAtamic aayojana satra','কৌশলগত পরিকল্পনা সেশন'], lang),
    _s(['Learn new framework (2hr)','新しいフレームワーク学習 (2時間)','Neues Framework lernen (2 Std.)','새 프레임워크 학습 (2시간)','Apprendre nouveau framework (2h)','学习新框架 (2小时)','Aprender nuevo framework (2h)','Aprender novo framework (2h)','नया फ्रेमवर्क सीखें (2 घंटे)','تعلم إطار عمل جديد (ساعتان)','కొత్త ఫ్రేమ్‌వర్క్ నేర్చుకోండి (2 గంటలు)','Imparare nuovo framework (2h)','Nieuw framework leren (2u)','புதிய கட்டமைப்பு கற்கவும் (2 மணி)','ಹೊಸ ಫ್ರೇಮ್‌ವರ್ಕ್ ಕಲಿಯಿರಿ (2 ತಾ)','പു‌തി‌യ ഫ്രേ‌ം‌വ‌ർ‌ക്ക് പ‌ഠി‌ക്കുക (2 മ‌ണി)','नवीन फ्रेमवर्क शिका (2 तास)','navaun framework shikho (2 kaLak)','নতুন ফ্রেমওয়ার্ক শিখুন (২ ঘণ্টা)'], lang),
    _s(['Review investment portfolio','投資ポートフォリオ確認','Anlageportfolio überprüfen','투자 포트폴리오 검토','Réviser le portefeuille','审查投资组合','Revisar cartera de inversiones','Revisar portfólio de investimentos','निवेश पोर्टफोलियो की समीक्षा','مراجعة محفظة الاستثمار','పెట్టుబడి పోర్ట్‌ఫోలియో సమీక్షించండి','Revisionare il portafoglio di investimenti','Beleggingsportefeuille beoordelen','முதலீட்டு போர்ட்ஃபோலியோ மதிப்பாய்வு','ಹೂಡಿಕೆ ಪೋರ್ಟ್‌ಫೋಲಿಯೋ ಪರಿಶೀಲಿಸಿ','നി‌ക്ഷേ‌പ പോ‌ർ‌ട്ട്‌ഫോ‌ളി‌യോ അ‌വ‌ലോ‌ക‌നം','गुंतवणूक पोर्टफोलिओ तपासा','rokaN portfolio ni samiksha','বিনিয়োগ পোর্টফোলিও পর্যালোচনা'], lang),
    _s(['1:1 with mentor','メンターと1対1','1:1 mit dem Mentor','멘토와 1:1','1:1 avec le mentor','与导师一对一','1:1 con el mentor','1:1 com o mentor','मेंटर के साथ 1:1','جلسة فردية مع المرشد','మెంటార్‌తో 1:1','1:1 con il mentore','1:1 met de mentor','வழிகாட்டியுடன் 1:1','ಮಾರ್ಗದರ್ಶಕರೊಂದಿಗೆ 1:1','മെ‌ൻ‌ററിനൊ‌പ്പം 1:1','मार्गदर्शकासोबत 1:1','margadarshak sathe 1:1','পরামর্শদাতার সাথে 1:1'], lang),
  ];
  final q2Rows = [
    (q2Titles[0], 'Today · Score 8.4',    today.add(const Duration(hours: 12, minutes: 30)), false, true,  8.4,  null,      true,  0),
    (q2Titles[1], 'Today',                today.add(const Duration(hours: 7, minutes: 30)),  false, false, null, '↻ Daily', false, 1),
    (q2Titles[2], 'Apr 14 ⏰',            null,  true,  false, null,  null,     false, 2),
    (q2Titles[3], 'This week · Score 8.1', null, false, false, 8.1,  null,      false, 3),
    (q2Titles[4], 'Fri · Score 7.6',      null,  false, false, 7.6,  null,      false, 4),
    (q2Titles[5], 'Next week · Score 7.4', null, false, false, 7.4,  null,      false, 5),
    (q2Titles[6], 'Thu · Score 7.2',      null,  false, false, 7.2,  null,      false, 6),
    (q2Titles[7], 'Sat',                  null,  false, false, null, '↻ Weekly',false, 7),
    (q2Titles[8], 'Sun · Score 6.9',      null,  false, false, 6.9,  null,      false, 8),
    (q2Titles[9], 'Wed · Score 6.7',      null,  false, false, 6.7,  null,      false, 9),
  ];
  for (final t in q2Rows) {
    await db.tasksDao.insertTask(TasksCompanion(
      title:           Value(t.$1),
      quadrant:        const Value(2),
      dueDate:         Value(t.$3),
      dueLabel:        Value(t.$2),
      isOverdue:       Value(t.$4),
      hasAi:           Value(t.$5),
      urgencyScore:    Value(t.$6),
      recurrenceLabel: Value(t.$7),
      hasPomodoro:     Value(t.$8),
      sortOrder:       Value(t.$9),
    ));
  }

  // Q3 — Urgent, Not Important
  final q3Titles = [
    _s(['Reply to group project messages','グループPJメッセージに返信','Gruppenproject-Nachrichten beantworten','그룹 프로젝트 메시지 답장','Répondre aux messages projet groupe','回复小组项目消息','Responder mensajes proyecto grupal','Responder mensagens do projeto em grupo','ग्रुप प्रोजेक्ट मैसेज का जवाब दें','الرد على رسائل المشروع الجماعي','గ్రూప్ ప్రాజెక్ట్ సందేశాలకు జవాబు ఇవ్వండి','Rispondere ai messaggi del progetto di gruppo','Groepsprojectberichten beantwoorden','குழு திட்ட செய்திகளுக்கு பதிலளிக்கவும்','ಗ್ರೂಪ್ ಪ್ರಾಜೆಕ್ಟ್ ಸಂದೇಶಗಳಿಗೆ ಉತ್ತರಿಸಿ','ഗ്രൂ‌പ്പ് പ്രോ‌ജ‌ക്ട് സ‌ന്ദേ‌ശ‌ങ്ങ‌ൾ‌ക്ക് മ‌റു‌പ‌ടി','गट प्रकल्प संदेशांना उत्तर द्या','group project message no javab apo','গ্রুপ প্রজেক্ট বার্তায় উত্তর দিন'], lang),
    _s(['Update family WhatsApp group','家族のWhatsAppグループ更新','Familie-WhatsApp-Gruppe aktualisieren','가족 WhatsApp 그룹 업데이트','Mettre à jour groupe WhatsApp famille','更新家庭WhatsApp群','Actualizar grupo WhatsApp familiar','Atualizar grupo WhatsApp da família','पारिवारिक WhatsApp ग्रुप अपडेट करें','تحديث مجموعة واتساب العائلة','కుటుంబ వాట్సాప్ గ్రూప్ నవీకరించండి','Aggiornare il gruppo WhatsApp di famiglia','Familie WhatsApp-groep bijwerken','குடும்ப வாட்ஸ்அப் குழுவை புதுப்பிக்கவும்','ಕುಟುಂಬ ವಾಟ್ಸಾಪ್ ಗ್ರೂಪ್ ಅಪ್ಡೇಟ್ ಮಾಡಿ','കു‌ടും‌ബ WhatsApp ഗ്രൂ‌പ്പ് അ‌പ്‌ഡേ‌റ്റ്','कुटुंब व्हाट्सअॅप ग्रुप अपडेट करा','family WhatsApp group update karo','পরিবারের WhatsApp গ্রুপ আপডেট করুন'], lang),
    _s(['Book physio appointment','理学療法士の予約','Physiotherapie-Termin buchen','물리치료 예약','Prendre RDV chez le kiné','预约理疗师','Reservar cita con fisioterapeuta','Marcar consulta com fisioterapeuta','फिजियो अपॉइंटमेंट बुक करें','حجز موعد مع المعالج الطبيعي','ఫిజియో అపాయింట్‌మెంట్ బుక్ చేయండి','Prenotare appuntamento dal fisioterapista','Fysiotherapieafspraak boeken','இயன்முறையாளர் நியமனம் பதிவு செய்யவும்','ಫಿಸಿಯೋ ಅಪಾಯಿಂಟ್‌ಮೆಂಟ್ ಬುಕ್ ಮಾಡಿ','ഫി‌സി‌യോ അ‌പ്പോ‌യ‌ൻ‌ட്‌മെ‌ൻ്റ് ബുക്ക്','फिजिओ भेट बुक करा','physio appointment book karo','ফিজিও অ্যাপয়েন্টমেন্ট বুক করুন'], lang),
    _s(['Send thank you email to coach','コーチにお礼メールを送る','Dankes-E-Mail an Trainer senden','코치에게 감사 이메일 보내기','Envoyer email remerciement coach','给教练发感谢邮件','Enviar correo de gracias al entrenador','Enviar e-mail de agradecimento','कोच को थैंक यू ईमेल भेजें','إرسال بريد شكر إلى المدرب','కోచ్‌కు ధన్యవాద ఇమెయిల్ పంపండి','Inviare email di ringraziamento al coach','Bedank-e-mail naar coach sturen','பயிற்றுனருக்கு நன்றி மின்னஞ்சல் அனுப்புங்கள்','ಕೋಚ್‌ಗೆ ಧನ್ಯವಾದ ಇಮೇಲ್ ಕಳುಹಿಸಿ','കോ‌ച്ചി‌ന് ന‌ന്ദി ഇ‌മെ‌യി‌ൽ അ‌യ‌ക്കുക','प्रशिक्षकाला धन्यवाद ईमेल पाठवा','coach ne thank you email moko','কোচকে ধন্যবাদ ইমেইল পাঠান'], lang),
    _s(['Forward expense reports','経費報告書を転送','Spesenabrechnung weiterleiten','지출 보고서 전달','Transmettre les notes de frais','转发费用报告','Reenviar informes de gastos','Encaminhar relatórios de despesas','खर्च रिपोर्ट आगे भेजें','إعادة توجيه تقارير المصروفات','వ్యయ నివేదికలు ఫార్వర్డ్ చేయండి','Inviare i rapporti di spesa','Onkostendeclaraties doorsturen','செலவு அறிக்கைகளை அனுப்புங்கள்','ವೆಚ್ಚದ ವರದಿಗಳನ್ನು ಫಾರ್ವರ್ಡ್ ಮಾಡಿ','ച‌ε‌ε‌λ‌വ് റി‌പ്പോ‌ർ‌ട്ടു‌കൾ ഫോ‌ർ‌വേ‌ഡ്','खर्च अहवाल पुढे पाठवा','kharch report forward karo','ব্যয়ের প্রতিবেদন ফরোয়ার্ড করুন'], lang),
    _s(['Schedule team interviews','チームの面接をスケジュール','Team-Interviews planen','팀 면접 일정 잡기','Planifier les entretiens d\'équipe','安排团队面试','Programar entrevistas de equipo','Agendar entrevistas da equipe','टीम इंटरव्यू शेड्यूल करें','جدولة مقابلات الفريق','జట్టు ఇంటర్వ్యూలు షెడ్యూల్ చేయండి','Programmare i colloqui del team','Teamgesprekken inplannen','குழு நேர்காணல்கள் திட்டமிடவும்','ತಂಡದ ಸಂದರ್ಶನಗಳನ್ನು ನಿಗದಿ ಮಾಡಿ','ടീം ഇ‌ൻ‌ട‌ർ‌വ്യൂ ഷെ‌ഡ്യൂ‌ൾ','संघ मुलाखती नियोजित करा','team interviews schedule karo','টিম ইন্টারভিউ নির্ধারণ করুন'], lang),
    _s(['Confirm vendor meeting time','ベンダーミーティング時間を確認','Lieferanten-Meeting-Zeit bestätigen','벤더 미팅 시간 확인','Confirmer heure réunion fournisseur','确认供应商会议时间','Confirmar hora reunión con proveedor','Confirmar horário reunião fornecedor','वेंडर मीटिंग का समय कन्फर्म करें','تأكيد وقت اجتماع المورد','విక్రేత సమావేశ సమయం నిర్ధారించండి','Confermare l\'orario riunione con il fornitore','Vergadertijd met leverancier bevestigen','விற்பனையாளர் கூட்ட நேரம் உறுதிப்படுத்தவும்','ವೆಂಡರ್ ಸಭೆಯ ಸಮಯ ದೃಢೀಕರಿಸಿ','വെ‌ൻ‌ഡ‌ർ മീ‌റ്റിം‌ഗ് സ‌മ‌യം സ്ഥി‌രീ‌ക‌രി‌ക്കുക','विक्रेता बैठकीची वेळ निश्चित करा','vendor meeting no samay confirm karo','ভেন্ডার মিটিং সময় নিশ্চিত করুন'], lang),
    _s(['Respond to recruiter inquiries','リクルーターの問い合わせに返答','Auf Recruiter-Anfragen antworten','헤드헌터 문의 응답','Répondre aux demandes recruteur','回复招聘者询问','Responder consultas del reclutador','Responder consultas do recrutador','रिक्रूटर की पूछताछ का जवाब दें','الرد على استفسارات المجند','రిక్రూటర్ విచారణలకు స్పందించండి','Rispondere alle richieste dei recruiter','Reageren op recruitersvragen','ஆட்சேர்ப்பாளர் விசாரணைகளுக்கு பதிலளிக்கவும்','ನೇಮಕಾತಿ ವ್ಯಕ್ತಿಯ ವಿಚಾರಣೆಗಳಿಗೆ ಉತ್ತರಿಸಿ','റി‌ക്രൂ‌ട്ട‌ർ അ‌ന്വേ‌ഷ‌ണ‌ങ്ങ‌ൾ‌ക്ക് പ്ര‌തി‌ക‌രി‌ക്കുക','भर्ती करणाऱ्याच्या विचारणांना उत्तर द्या','recruiter ni vicharna no javab apo','নিয়োগকর্তার অনুসন্ধানে সাড়া দিন'], lang),
    _s(['Coordinate office lunch order','オフィスランチの注文を調整','Büro-Mittagessen koordinieren','사무실 점심 주문 조율','Coordonner commande déjeuner bureau','协调办公室午餐订单','Coordinar pedido almuerzo oficina','Coordenar pedido almoço do escritório','ऑफिस लंच ऑर्डर कोऑर्डिनेट करें','تنسيق طلب غداء المكتب','ఆఫీస్ భోజన ఆర్డర్ సమన్వయించండి','Coordinare l\'ordine del pranzo in ufficio','Kantoorlunchbestelling coördineren','அலுவலக மதிய உணவு ஆர்டர் ஒருங்கிணைக்கவும்','ಕಚೇರಿ ಊಟದ ಆರ್ಡರ್ ಸಮನ್ವಯಿಸಿ','ഓ‌ഫീ‌സ് ഉ‌ച്ച‌ഭ‌ക്ഷ‌ണ ഓ‌ർ‌ഡ‌ർ ഏ‌കോ‌പ‌ന','कार्यालय दुपारचे जेवण ऑर्डर समन्वय','office lunch order samaavit karo','অফিস লাঞ্চ অর্ডার সমন্বয় করুন'], lang),
    _s(['Acknowledge LinkedIn requests','LinkedInのリクエストを承認','LinkedIn-Anfragen bestätigen','LinkedIn 요청 수락','Accepter les demandes LinkedIn','处理LinkedIn请求','Aceptar solicitudes de LinkedIn','Aceitar solicitações do LinkedIn','LinkedIn अनुरोध स्वीकार करें','قبول طلبات LinkedIn','LinkedIn అభ్యర్థనలు స్వీకరించండి','Accettare le richieste di LinkedIn','LinkedIn-verzoeken accepteren','LinkedIn கோரிக்கைகளை ஏற்கவும்','LinkedIn ವಿನಂತಿಗಳನ್ನು ಸ್ವೀಕರಿಸಿ','LinkedIn അ‌ഭ്യ‌ർ‌ത്ഥ‌ന‌കൾ സ്വീ‌ക‌രി‌ക്കുക','LinkedIn विनंत्या स्वीकारा','LinkedIn request swikaar karo','LinkedIn অনুরোধ গ্রহণ করুন'], lang),
  ];
  final q3Labels = [
    'Today', 'This week', 'Tomorrow', 'Today', 'Today',
    'This week', 'Tomorrow', 'This week', 'Fri', 'Today',
  ];
  for (var i = 0; i < q3Titles.length; i++) {
    await db.tasksDao.insertTask(TasksCompanion(
      title:     Value(q3Titles[i]),
      quadrant:  const Value(3),
      dueLabel:  Value(q3Labels[i]),
      sortOrder: Value(i),
    ));
  }

  // Q4 — Not Urgent, Not Important
  final q4Titles = [
    _s(['Reorganise desktop folders','デスクトップフォルダを整理','Desktop-Ordner neu ordnen','데스크탑 폴더 정리','Réorganiser dossiers bureau','整理桌面文件夹','Reorganizar carpetas escritorio','Reorganizar pastas área de trabalho','डेस्कटॉप फोल्डर को दोबारा व्यवस्थित करें','إعادة تنظيم مجلدات سطح المكتب','డెస్క్‌టాప్ ఫోల్డర్లు పునర్వ్యవస్థీకరించండి','Riorganizzare le cartelle del desktop','Bureaubladmappen herorganiseren','டெஸ்க்டாப் கோப்புறைகளை மறுவரிசைப்படுத்தவும்','ಡೆಸ್ಕ್‌ಟಾಪ್ ಫೋಲ್ಡರ್‌ಗಳನ್ನು ಮರುಸಂಘಟಿಸಿ','ഡെ‌സ്‌ക്‌ടോ‌പ്പ് ഫോ‌ൾ‌ഡ‌റു‌കൾ പു‌ന‌ഃ‌ക്ര‌മീ‌ക‌രി‌ക്കുക','डेस्कटॉप फोल्डर पुनर्व्यवस्थित करा','desktop folders ne farthi vyavasthit karo','ডেস্কটপ ফোল্ডার পুনর্গঠন করুন'], lang),
    _s(['Clean up old screenshots','古いスクリーンショットを整理','Alte Screenshots aufräumen','오래된 스크린샷 정리','Nettoyer les vieilles captures','清理旧截图','Limpiar capturas de pantalla antiguas','Limpar capturas de tela antigas','पुराने स्क्रीनशॉट साफ करें','تنظيف لقطات الشاشة القديمة','పాత స్క్రీన్‌షాట్‌లు శుభ్రపరచండి','Eliminare i vecchi screenshot','Oude schermafbeeldingen opruimen','பழைய திரைக்காட்சிகளை சுத்தப்படுத்தவும்','ಹಳೆಯ ಸ್ಕ್ರೀನ್‌ಶಾಟ್‌ಗಳನ್ನು ಅಳಿಸಿ','പ‌ഴ‌യ സ്‌ക്രീ‌ൻ‌ഷോ‌ട്ടു‌കൾ ഡി‌ലീ‌റ്റ് ‌ചെ‌യ്യുക','जुने स्क्रीनशॉट साफ करा','juna screenshots saaf karo','পুরানো স্ক্রিনশট পরিষ্কার করুন'], lang),
    _s(['Sort through old emails','古いメールを整理','Alte E-Mails sortieren','오래된 이메일 정리','Trier les anciens e-mails','整理旧邮件','Ordenar correos electrónicos antiguos','Organizar e-mails antigos','पुराने ईमेल सॉर्ट करें','فرز رسائل البريد الإلكتروني القديمة','పాత ఇమెయిల్‌లు వర్గీకరించండి','Ordinare le vecchie e-mail','Oude e-mails doorzoeken','பழைய மின்னஞ்சல்களை வரிசைப்படுத்தவும்','ಹಳೆಯ ಇಮೇಲ್‌ಗಳನ್ನು ವಿಂಗಡಿಸಿ','പ‌ഴ‌യ ഇ‌മെ‌യി‌ലു‌കൾ ക്ര‌മ‌പ്പെ‌ടു‌ത്തുക','जुने ईमेल सॉर्ट करा','juna emails sort karo','পুরানো ইমেইল সাজান'], lang),
    _s(['Browse productivity tools (again)','生産性ツールを（また）調べる','Produktivitätstools durchstöbern','생산성 도구 탐색 (또)','Parcourir outils productivité (encore)','（再次）浏览效率工具','Explorar herramientas productividad','Explorar ferramentas produtividade','प्रोडक्टिविटी टूल ब्राउज़ करें (फिर)','تصفح أدوات الإنتاجية مرة أخرى','ఉత్పాదకత సాధనాలు తిరిగి చూడండి','Sfogliare strumenti produttività (ancora)','Productiviteitstools doorzoeken (opnieuw)','உற்பத்தித்திறன் கருவிகளை மீண்டும் பார்க்கவும்','ಮತ್ತೆ ಉತ್ಪಾದಕತೆ ಸಾಧನಗಳನ್ನು ಹುಡುಕಿ','ഉ‌ൽ‌പ്പാ‌ദ‌ന‌ക്ഷ‌മ‌ത ഉ‌പ‌ക‌ര‌ണ‌ങ്ങൾ വീ‌ണ്ടും','उत्पादकता साधने पुन्हा पाहा','utpadakta tools farthi jovo','আবার উৎপাদনশীলতা সরঞ্জাম দেখুন'], lang),
    _s(['Reorganise photo library','写真ライブラリを整理','Fotobibliothek neu ordnen','사진 라이브러리 정리','Réorganiser la bibliothèque de photos','整理照片库','Reorganizar biblioteca de fotos','Reorganizar biblioteca de fotos','फोटो लाइब्रेरी को दोबारा व्यवस्थित करें','إعادة تنظيم مكتبة الصور','ఫోటో లైబ్రరీ పునర్వ్యవస్థీకరించండి','Riorganizzare la libreria fotografica','Fotobibliotheek herorganiseren','புகைப்பட நூலகத்தை மறுவரிசைப்படுத்தவும்','ಫೋಟೋ ಲೈಬ್ರರಿ ಮರುಸಂಘಟಿಸಿ','ഫോ‌ട്ടോ ലൈ‌ബ്ര‌റി പു‌ന‌ഃ‌ക്ര‌മീ‌ക‌രി‌ക്കുക','फोटो लायब्ररी पुनर्व्यवस्थित करा','photo library ne farthi vyavasthit karo','ফটো লাইব্রেরি পুনর্গঠন করুন'], lang),
    _s(['Watch "documentary" on productivity','生産性「ドキュメンタリー」を見る','"Doku" über Produktivität schauen','생산성 "다큐멘터리" 시청','Voir "documentaire" productivité','观看效率"纪录片"','Ver "documental" sobre productividad','Assistir "documentário" produtividade','प्रोडक्टिविटी "डॉक्यूमेंट्री" देखें','مشاهدة "وثائقي" الإنتاجية','ఉత్పాదకత "డాక్యుమెంటరీ" చూడండి','Guardare "documentario" sulla produttività','Productiviteits"documentaire" bekijken','உற்பத்தித்திறனில் "ஆவணப்படம்" பார்க்கவும்','ಉತ್ಪಾದಕತೆಯ "ಡಾಕ್ಯುಮೆಂಟರಿ" ನೋಡಿ','ഉ‌ൽ‌പ്പാ‌ദ‌ന‌ക്ഷ‌മ‌ത "ഡോ‌ക്യു‌മെ‌ൻ‌ററി" ക‌ണ്ടു','उत्पादकतेवर "माहितीपट" पाहा','"documentary" jovo utpadakta par','উৎপাদনশীলতার "ডকুমেন্টারি" দেখুন'], lang),
    _s(['Rewrite old blog posts','古いブログ記事を書き直す','Alte Blogbeiträge überarbeiten','오래된 블로그 재작성','Réécrire les anciens articles de blog','重写旧博客文章','Reescribir publicaciones blog antiguas','Reescrever posts antigos do blog','पुरानी ब्लॉग पोस्ट दोबारा लिखें','إعادة كتابة المدونات القديمة','పాత బ్లాగ్ పోస్ట్‌లు తిరిగి రాయండి','Riscrivere i vecchi articoli del blog','Oude blogposts herschrijven','பழைய வலைப்பதிவுகளை மீண்டும் எழுதவும்','ಹಳೆಯ ಬ್ಲಾಗ್ ಪೋಸ್ಟ್‌ಗಳನ್ನು ಮರು-ಬರೆಯಿರಿ','പ‌ഴ‌യ ബ്ലോ‌ഗ് പോ‌സ്റ്റു‌കൾ പു‌ന‌ഃ‌ര‌ചി‌ക്കുക','जुन्या ब्लॉग पोस्ट पुन्हा लिहा','juna blog posts farthi lakho','পুরানো ব্লগ পোস্ট পুনর্লিখন করুন'], lang),
    _s(['Research best standing desk','最高の昇降デスクをリサーチ','Besten Stehschreibtisch recherchieren','최고의 스탠딩 데스크 조사','Rechercher meilleur bureau debout','研究最佳站立式办公桌','Investigar el mejor escritorio de pie','Pesquisar melhor mesa de pé','बेस्ट स्टैंडिंग डेस्क रिसर्च करें','البحث عن أفضل مكتب وقوف','ఉత్తమ స్టాండింగ్ డెస్క్ పరిశోధించండి','Ricercare il miglior standing desk','Beste staand bureau onderzoeken','சிறந்த நிற்கும் மேசை ஆராயவும்','ಅತ್ಯುತ್ತಮ ಸ್ಟ್ಯಾಂಡಿಂಗ್ ಡೆಸ್ಕ್ ಹುಡುಕಿ','ഏ‌റ്റ‌വും ന‌ല്ല standing desk ഗ‌വേ‌ഷ‌ണ‌ം','सर्वोत्तम स्टँडिंग डेस्क संशोधन','saaro standing desk khojo','সেরা স্ট্যান্ডিং ডেস্ক গবেষণা করুন'], lang),
    _s(['Update LinkedIn header photo','LinkedInのヘッダー写真を更新','LinkedIn-Header-Foto aktualisieren','LinkedIn 헤더 사진 업데이트','Mettre à jour photo en-tête LinkedIn','更新LinkedIn封面照片','Actualizar foto portada LinkedIn','Atualizar foto capa do LinkedIn','LinkedIn हेडर फोटो अपडेट करें','تحديث صورة الغلاف في LinkedIn','LinkedIn హెడర్ ఫోటో నవీకరించండి','Aggiornare la foto di copertina LinkedIn','LinkedIn-omslagfoto bijwerken','LinkedIn தலைப்பு புகைப்படம் புதுப்பிக்கவும்','LinkedIn ಹೆಡರ್ ಫೋಟೋ ಅಪ್ಡೇಟ್ ಮಾಡಿ','LinkedIn ഹെ‌ഡ‌ർ ഫോ‌ട്ടോ അ‌പ്‌ഡേ‌റ്റ്','LinkedIn हेडर फोटो अपडेट करा','LinkedIn header photo update karo','LinkedIn হেডার ফটো আপডেট করুন'], lang),
    _s(['Make a "perfect" morning playlist','「完璧な」朝のプレイリストを作る','Die "perfekte" Morgen-Playlist erstellen','"완벽한" 아침 재생목록 만들기','Créer la "parfaite" playlist matinale','制作"完美"早晨播放列表','Crear la playlist matutina "perfecta"','Criar a playlist matinal "perfeita"','"परफेक्ट" सुबह की प्लेलिस्ट बनाएं','إنشاء قائمة تشغيل "مثالية" للصباح','"పరిపూర్ణ" ఉదయ ప్లేలిస్ట్ తయారు చేయండి','Creare la "perfetta" playlist mattutina','Een "perfecte" ochtendafspeellijst maken','"சரியான" காலை பாடல் பட்டியல் உருவாக்கவும்','"ಪರಿಪೂರ್ಣ" ಬೆಳಿಗ್ಗೆ ಪ್ಲೇಲಿಸ್ಟ್ ಮಾಡಿ','"മ‌നോ‌ഹ‌ര‌മാ‌യ" പ്ര‌ഭാ‌ത playlist','"परफेक्ट" सकाळची प्लेलिस्ट बनवा','"best" savare ni playlist banavo','"নিখুঁত" সকালের প্লেলিস্ট তৈরি করুন'], lang),
  ];
  for (var i = 0; i < q4Titles.length; i++) {
    await db.tasksDao.insertTask(TasksCompanion(
      title:     Value(q4Titles[i]),
      quadrant:  const Value(4),
      dueLabel:  const Value('Someday'),
      sortOrder: Value(i),
    ));
  }
}

// ── Habits ────────────────────────────────────────────────────────────────────

Future<void> _seedHabits(AppDatabase db, int lang) async {
  final habits = [
    (
      emoji: '🏃',
      name: _s(['Gym workout 💪','ジムワークアウト 💪','Fitnesstraining 💪','헬스 운동 💪','Entraînement salle 💪','健身锻炼 💪','Entrenamiento gym 💪','Treino academia 💪','जिम वर्कआउट 💪','تمرين الصالة 💪','జిమ్ వర్కౌట్ 💪','Allenamento in palestra 💪','Sportschooltraining 💪','உடற்பயிற்சி 💪','ಜಿಮ್ ವ್ಯಾಯಾಮ 💪','ജിം വ്യ‌ായ‌ാ‌മം 💪','जिम व्यायाम 💪','gym kasarat 💪','জিম ব্যায়াম 💪'], lang),
      freq: 'Mon · Wed · Fri · 60 min · Q2',
      duration: 60,
      time: 390, // 6:30 AM
      streak: '🔥 14d',
      streakColor: 0xFF9FCD44,
      accent: 0xFF7FBA00,
      filled: 5,
      subLabel: _s(['Today\'s routine','今日のルーティン','Heutiges Routine','오늘의 루틴','Routine du jour','今日例行','Rutina de hoy','Rotina de hoje','आज का रूटीन','روتين اليوم','ఈరోజు రూటీన్','Routine di oggi','Routine van vandaag','இன்றைய வழக்கம்','ಇಂದಿನ ದಿನಚರಿ','ഇ‌ന്നത്തെ ദി‌ന‌ച‌ര്യ','आजचे रूटीन','aajano routine','আজকের রুটিন'], lang),
      subs: [
        (_s(['Warm up 10 min','10分ウォームアップ','10 Min. aufwärmen','10분 워밍업','Échauffement 10 min','热身10分钟','Calentamiento 10 min','Aquecimento 10 min','10 मिनट वार्मअप','إحماء 10 دقائق','10 నిమిషాలు వేడెక్కించండి','Riscaldamento 10 min','10 min opwarmen','10 நிமிட வார்மப்','10 ನಿಮಿಷ ವಾರ್ಮ್ ಅಪ್','10 മി‌നി‌ട്ട് വ‌ാം അ‌പ്','10 मिनिट वार्मअप','10 min warm up','১০ মিনিট ওয়ার্মআপ'], lang), false),
        (_s(['Cold shower','冷水シャワー','Kalte Dusche','냉수 샤워','Douche froide','冷水澡','Ducha fría','Banho frio','ठंडा शॉवर','دش بارد','చల్లని స్నానం','Doccia fredda','Koude douche','குளிர் குளியல்','ತಣ್ಣನೆಯ ಸ್ನಾನ','ത‌ണു‌ത്ത കു‌ളി','थंड शॉवर','thando shower','ঠান্ডা গোসল'], lang), true),
        (_s(['Log distance','走行距離を記録','Distanz protokollieren','거리 기록','Enregistrer la distance','记录距离','Registrar distancia','Registrar distância','दूरी लॉग करें','تسجيل المسافة','దూరం నమోదు చేయండి','Registrare la distanza','Afstand bijhouden','தூரம் பதிவு','ದೂರ ದಾಖಲಿಸಿ','ദൂ‌രം ലോ‌ഗ് ‌ചെ‌യ്യുക','अंतर लॉग करा','antar note karo','দূরত্ব লগ করুন'], lang), false),
      ],
    ),
    (
      emoji: '✍️',
      name: _s(['Morning journaling','朝のジャーナリング','Morgentagebuch','아침 저널링','Journal du matin','晨间日记','Diario matutino','Diário matinal','सुबह जर्नलिंग','التأمل الصباحي','ఉదయం జర్నలింగ్','Diario mattutino','Ochtenddagboek','காலை குறிப்பேடு','ಬೆಳಿಗ್ಗೆ ಜರ್ನಲಿಂಗ್','ര‌ാ‌വി‌ലെ ജേ‌ർ‌ണ‌ലിം‌ഗ്','सकाळचे लेखन','savare ni diary','সকালের জার্নালিং'], lang),
      freq: 'Daily · 15 min · Q2',
      duration: 15,
      time: 420, // 7:00 AM
      streak: '🔥 7d',
      streakColor: 0xFF409CFF,
      accent: 0xFF0A84FF,
      filled: 6,
      subLabel: _s(['Sub-habits','サブ習慣','Teilgewohnheiten','하위 습관','Sous-habitudes','子习惯','Sub-hábitos','Sub-hábitos','उप-आदतें','عادات فرعية','ఉప-అలవాట్లు','Sotto-abitudini','Deelgewoonten','துணை பழக்கங்கள்','ಉಪ-ಅಭ್ಯಾಸಗಳು','ഉ‌പ-‌ശീ‌ല‌ങ്ങൾ','उप-सवयी','upni tevo','উপ-অভ্যাস'], lang),
      subs: [
        (_s(['Gratitude 3 items','感謝3項目','Dankbarkeit 3 Punkte','감사 3가지','3 choses de gratitude','感恩3件事','3 cosas de gratitud','3 coisas de gratidão','3 कृतज्ञता आइटम','ثلاثة أشياء للامتنان','కృతజ్ఞత 3 అంశాలు','3 cose per cui essere grati','3 dankbaarheidspunten','கೃतజ்ஞதை 3 விஷயங்கள்','ಕೃತಜ್ಞತೆ 3 ವಿಷಯಗಳು','ക‌ൃ‌ത‌ജ്ഞ‌ത 3 വി‌ഷ‌യ‌ങ്ങൾ','कृतज्ञता 3 गोष्टी','3 aabhaar ni vaato','কৃতজ্ঞতা ৩টি বিষয়'], lang), true),
        (_s(['Intentions for the day','今日の意図','Absichten für den Tag','오늘의 의도','Intentions du jour','今天的意图','Intenciones del día','Intenções do dia','दिन के इरादे','نوايا اليوم','రోజు లక్ష్యాలు','Intenzioni per il giorno','Intenties voor de dag','நாளின் நோக்கங்கள்','ದಿನದ ಉದ್ದೇಶಗಳು','ദി‌വ‌സ‌ത്തി‌ൻ്റെ ഉ‌ദ്ദേ‌ശ്യ‌ങ്ങൾ','दिवसाचे उद्दिष्ट','divas maate irada','দিনের জন্য উদ্দেশ্য'], lang), false),
        (_s(['Brain dump','ブレインダンプ','Gedanken entleeren','브레인 덤프','Vider son esprit','思维倾泻','Descarga mental','Despejo mental','ब्रेन डंप','تفريغ الأفكار','బ్రెయిన్ డంప్','Scarica mentale','Gedachten leeggooien','மூளை வெளியேற்றம்','ಬ್ರೇನ್ ಡಂಪ್','ബ്ര‌യ്ൻ ഡ‌ംപ്','ब्रेन डंप','brain dump','ব্রেইন ডাম্প'], lang), false),
      ],
    ),
    (
      emoji: '💪',
      name: _s(['Strength training','筋力トレーニング','Krafttraining','근력 훈련','Musculation','力量训练','Entrenamiento de fuerza','Treinamento de força','स्ट्रेंथ ट्रेनिंग','تدريب القوة','బలపు శిక్షణ','Allenamento di forza','Krachttraining','வலிமை பயிற்சி','ಬಲ ತರಬೇತಿ','ശ‌ക്തി പ‌രി‌ശീ‌ല‌നം','शक्ती प्रशिक्षण','shakti talim','শক্তি প্রশিক্ষণ'], lang),
      freq: 'Mon · Wed · Fri · Q2',
      duration: null,
      time: 1080, // 6:00 PM
      streak: '🔥 3w',
      streakColor: 0xFFBF5AF2,
      accent: 0xFFBF5AF2,
      filled: 3,
      subLabel: _s(['Sub-habits','サブ習慣','Teilgewohnheiten','하위 습관','Sous-habitudes','子习惯','Sub-hábitos','Sub-hábitos','उप-आदतें','عادات فرعية','ఉప-అలవాట్లు','Sotto-abitudini','Deelgewoonten','துணை பழக்கங்கள்','ಉಪ-ಅಭ್ಯಾಸಗಳು','ഉ‌പ-‌ശീ‌ല‌ങ്ങൾ','उप-सवयी','upni tevo','উপ-অভ্যাস'], lang),
      subs: [
        (_s(['Warm up 5 min','5分ウォームアップ','5 Min. aufwärmen','5분 워밍업','Échauffement 5 min','热身5分钟','Calentamiento 5 min','Aquecimento 5 min','5 मिनट वार्मअप','إحماء 5 دقائق','5 నిమిషాలు వేడెక్కించండి','Riscaldamento 5 min','5 min opwarmen','5 நிமிட வார்மப்','5 ನಿಮಿಷ ವಾರ್ಮ್ ಅಪ್','5 മി‌നി‌ട്ട് വ‌ാം അ‌പ്','5 मिनिट वार्मअप','5 min warm up','৫ মিনিট ওয়ার্মআপ'], lang), true),
        (_s(['Main lifts','メインリフト','Hauptheben','메인 리프트','Exercices principaux','主要举重','Levantamientos principales','Levantamentos principais','मेन लिफ्ट्स','رفع الثقل الأساسي','ప్రధాన లిఫ్ట్స్','Sollevamenti principali','Hoofdlifts','முக்கிய தூக்குதல்கள்','ಮುಖ್ಯ ಲಿಫ್ಟ್‌ಗಳು','പ്ര‌ധാ‌ന ലി‌ഫ്‌റ്റ്','मुख्य लिफ्ट','mukhy lifts','মূল লিফটস'], lang), true),
        (_s(['Cool down + stretch','クールダウン + ストレッチ','Abkühlen + Dehnen','쿨다운 + 스트레칭','Récupération + étirements','放松 + 拉伸','Enfriamiento + estiramientos','Desaquecimento + alongamento','कूल डाउन + स्ट्रेच','تهدئة + تمدد','కూల్ డౌన్ + స్ట్రెచ్','Defaticamento + stretching','Afkoelen + rekken','குளிர்ச்சி + நீட்சி','ಕೂಲ್ ಡೌನ್ + ಸ್ಟ್ರೆಚ್','കൂൾ ഡ‌ൗ‌ൺ + സ്‌ട്രെ‌ച്ച്','कूल डाउन + स्ट्रेच','cool down + stretch','কুল ডাউন + স্ট্রেচ'], lang), false),
      ],
    ),
    (
      emoji: '📚',
      name: _s(['Read 30 min','30分読書','30 Min. lesen','30분 독서','Lire 30 min','阅读30分钟','Leer 30 min','Ler 30 min','30 मिनट पढ़ें','قراءة 30 دقيقة','30 నిమిషాలు చదవండి','Leggere 30 min','30 min lezen','30 நிமிடம் படிக்கவும்','30 ನಿಮಿಷ ಓದಿ','30 മി‌നി‌ട്ട് വ‌ായി‌ക്കുക','30 मिनिट वाचा','30 min vaaancho','৩০ মিনিট পড়ুন'], lang),
      freq: 'Daily · Q2 · 60% this week',
      duration: 30,
      time: 1260, // 9:00 PM
      streak: '↻ Adapt',
      streakColor: 0xFFFFB900,
      accent: 0xFFFFB900,
      filled: 3,
      subLabel: _s(['Sub-habits','サブ習慣','Teilgewohnheiten','하위 습관','Sous-habitudes','子习惯','Sub-hábitos','Sub-hábitos','उप-आदतें','عادات فرعية','ఉప-అలవాట్లు','Sotto-abitudini','Deelgewoonten','துணை பழக்கங்கள்','ಉಪ-ಅಭ್ಯಾಸಗಳು','ഉ‌പ-‌ശീ‌ല‌ങ്ങൾ','उप-सवयी','upni tevo','উপ-অভ্যাস'], lang),
      subs: [
        (_s(['Pick a chapter','章を選ぶ','Kapitel auswählen','챕터 선택','Choisir un chapitre','选择一章','Elegir un capítulo','Escolher um capítulo','एक अध्याय चुनें','اختيار فصل','ఒక అధ్యాయం ఎంచుకోండి','Scegliere un capitolo','Een hoofdstuk kiezen','ஒரு அத்தியாயம் தேர்ந்தெடுக்கவும்','ಒಂದು ಅಧ್ಯಾಯ ಆರಿಸಿ','ഒ‌രു അ‌ദ്ധ്യ‌ായം തി‌ര‌ഞ്ഞെ‌ടു‌ക്കുക','एक प्रकरण निवडा','ek chapter pasand karo','একটি অধ্যায় বেছে নিন'], lang), false),
        (_s(['Take notes','メモを取る','Notizen machen','노트 적기','Prendre des notes','记笔记','Tomar notas','Fazer anotações','नोट्स लें','أخذ ملاحظات','నోట్స్ తీసుకోండి','Prendere appunti','Notities maken','குறிப்புகள் எடுக்கவும்','ಟಿಪ್ಪಣಿ ಮಾಡಿ','കു‌റി‌പ്പു‌കൾ എ‌ടു‌ക്കുക','नोट्स घ्या','notes lo','নোট নিন'], lang), false),
      ],
    ),
  ];

  for (final h in habits) {
    final id = await db.habitsDao.insertHabit(HabitsCompanion(
      emoji:             Value(h.emoji),
      name:              Value(h.name),
      frequencyLabel:    Value(h.freq),
      durationMinutes:   Value(h.duration),
      scheduledTime:     Value(h.time),
      streakLabel:       Value(h.streak),
      streakColorValue:  Value(h.streakColor),
      accentColorValue:  Value(h.accent),
      weeklyFilledCount: Value(h.filled),
      subLabel:          Value(h.subLabel),
    ));
    for (var i = 0; i < h.subs.length; i++) {
      await db.habitsDao.insertSubHabit(SubHabitsCompanion(
        habitId:   Value(id),
        title:     Value(h.subs[i].$1),
        isDone:    Value(h.subs[i].$2),
        sortOrder: Value(i),
      ));
    }
  }
}

// ── Goals ─────────────────────────────────────────────────────────────────────

Future<void> _seedGoals(AppDatabase db, int lang) async {
  final mvpGoalId = await db.goalsDao.insertGoal(GoalsCompanion(
    emoji:            const Value('🚀'),
    emojiBg:          const Value('0x1A0A84FF'),
    title:            Value(_s(['Launch MVP by June','6月までにMVPリリース','MVP bis Juni launchen','6월까지 MVP 출시','Lancer le MVP avant juin','六月前发布MVP','Lanzar MVP antes de junio','Lançar MVP até junho','जून तक MVP लॉन्च करें','إطلاق MVP بحلول يونيو','జూన్ నాటికి MVP విడుదల చేయండి','Lanciare MVP entro giugno','MVP lanceren voor juni','ஜூன் வரை MVP வெளியிடவும்','ಜೂನ್‌ವರೆಗೆ MVP ಬಿಡುಗಡೆ','ജൂ‌ണ്‌ ‌വ‌രെ MVP ‌ലോ‌ഞ്ച്','जूनपर्यंत MVP लाँच','June sudhi MVP launch karo','জুনের মধ্যে MVP লঞ্চ'], lang)),
    subtitle:         Value(_s(['42 days left · Q2 focus','残り42日·Q2フォーカス','Noch 42 Tage·Q2-Fokus','42일 남음·Q2 집중','42 jours restants·Focus Q2','剩余42天·Q2重点','42 días restantes·Foco Q2','42 dias restantes·Foco Q2','42 दिन बाकी·Q2 फोकस','42 يوماً متبقياً·تركيز Q2','42 రోజులు మిగిలాయి · Q2 దృష్టి','42 giorni rimasti·Focus Q2','42 dagen over·Q2 focus','42 நாட்கள் மீதம் · Q2 கவனம்','42 ದಿನ ಬಾಕಿ · Q2 ಗಮನ','42 ദി‌വ‌സം ‌ബ‌ാ‌ക്കി · Q2 ‌ഫോ‌ക്ക‌സ്','42 दिवस बाकी·Q2 लक्ष','42 din bakee · Q2 dhyan','৪২ দিন বাকি · Q2 ফোকাস'], lang)),
    progressPct:      const Value(0.60),
    accentColorValue: const Value(0xFF0A84FF),
    barColorValue:    const Value(0xFF0A84FF),
    borderColorValue: const Value(0x330A84FF),
    linkedLabel:      Value(_s(['Linked Q2 tasks · 6/10','リンクQ2タスク·6/10','Verbundene Q2-Aufgaben·6/10','연결된 Q2 작업·6/10','Tâches Q2 liées·6/10','关联Q2任务·6/10','Tareas Q2 vinculadas·6/10','Tarefas Q2 vinculadas·6/10','लिंक्ड Q2 टास्क·6/10','مهام Q2 المرتبطة·6/10','అనుసంధానిత Q2 టాస్క్‌లు · 6/10','Attività Q2 collegate · 6/10','Gekoppelde Q2-taken · 6/10','இணைந்த Q2 பணிகள் · 6/10','ಸಂಪರ್ಕಿತ Q2 ಕಾರ್ಯಗಳು · 6/10','ബ‌ന്ധി‌പ്പി‌ച്ച Q2 ‌ടാ‌സ്‌കു‌കൾ · 6/10','लिंक केलेले Q2 कार्य · 6/10','jodayelaa Q2 tasks · 6/10','সংযুক্ত Q2 কাজ · 6/10'], lang)),
    linkType:         const Value('task'),
    dotColorValue:    const Value(0xFF0A84FF),
  ));

  final exerciseGoalId = await db.goalsDao.insertGoal(GoalsCompanion(
    emoji:            const Value('💪'),
    emojiBg:          const Value('0x1ABF5AF2'),
    title:            Value(_s(['Build consistent exercise habit','一貫した運動習慣を築く','Konsistente Übungsgewohnheit aufbauen','일관된 운동 습관 만들기','Construire un régime d\'exercice régulier','建立一致的锻炼习惯','Construir hábito de ejercicio consistente','Construir hábito de exercício consistente','लगातार व्यायाम की आदत बनाएं','بناء عادة التمرين المستمرة','స్థిరమైన వ్యాయామ అలవాటు పెంచుకోండి','Costruire un\'abitudine di esercizio costante','Consistente trainingsgewoonte opbouwen','தொடர்ச்சியான உடற்பயிற்சி பழக்கம் உருவாக்கவும்','ನಿರಂತರ ವ್ಯಾಯಾಮ ಅಭ್ಯಾಸ ಬೆಳೆಸಿ','സ്ഥി‌ര‌ത‌യു‌ള്ള വ്യ‌ായ‌ാ‌മ ‌ശീ‌ലം','सातत्यपूर्ण व्यायामाची सवय निर्माण करा','satatni kasarat ni tev banavo','ধারাবাহিক ব্যায়ামের অভ্যাস গড়ুন'], lang)),
    subtitle:         Value(_s(['No deadline · ongoing','期限なし·継続中','Keine Deadline·laufend','마감 없음·진행 중','Sans délai·en cours','无截止日期·持续进行','Sin fecha límite·en curso','Sem prazo·em andamento','कोई डेडलाइन नहीं·जारी','بلا موعد نهائي·مستمر','గడువు లేదు · కొనసాగింపు','Nessuna scadenza·in corso','Geen deadline·lopend','காலக்கெடு இல்லை · தொடர்ச்சி','ಗಡುವಿಲ್ಲ · ನಡೆ‌ಯು‌ತ್ತಿ‌ದೆ','‌ഗ‌ഡു‌വി‌ല്ല · ‌തു‌ടർ‌ന്ന്','मुदत नाही · सुरू','koi deadline nathi · chalu','কোনো সময়সীমা নেই · চলমান'], lang)),
    progressPct:      const Value(0.43),
    accentColorValue: const Value(0xFFBF5AF2),
    barColorValue:    const Value(0xFFBF5AF2),
    borderColorValue: const Value(0x33BF5AF2),
    linkedLabel:      Value(_s(['Linked habits · 3/7 streaks this week','リンク習慣·今週3/7連続','Verknüpfte Gewohnheiten·3/7 Serien','연결된 습관·이번 주 3/7 연속','Habitudes liées·3/7 séries cette semaine','关联习惯·本周3/7连续','Hábitos vinculados·3/7 rachas esta semana','Hábitos vinculados·3/7 sequências','लिंक्ड हैबिट्स·इस सप्ताह 3/7 स्ट्रीक','العادات المرتبطة·3/7 تسلسلات هذا الأسبوع','అనుసంధానిత అలవాట్లు · ఈ వారం 3/7 స్ట్రీక్స్','Abitudini collegate·3/7 serie questa settimana','Gekoppelde gewoonten·3/7 reeksen deze week','இணைந்த பழக்கங்கள் · இந்த வாரம் 3/7','ಸಂಪರ್ಕಿತ ಅಭ್ಯಾಸಗಳು · ಈ ವಾರ 3/7','ബ‌ന്ധി‌പ്പി‌ച്ച ‌ശീ‌ല‌ങ്ങൾ · ‌ഈ ‌ആ‌ഴ്‌ച 3/7','लिंक केलेल्या सवयी · या आठवड्यात 3/7','jodeyli tevo · aa athi maaNe 3/7','সংযুক্ত অভ্যাস · এই সপ্তাহে ৩/৭ স্ট্রিক'], lang)),
    linkType:         const Value('habit'),
    dotColorValue:    const Value(0xFFBF5AF2),
  ));

  // ── Real links (so the goal metadata + linked rows are live, not static) ────
  // MVP goal → all Q2 ("Schedule") tasks.
  final q2Tasks = await (db.select(db.tasks)..where((t) => t.quadrant.equals(2))).get();
  for (final t in q2Tasks) {
    await db.goalsDao.insertTaskLink(
      GoalTaskLinksCompanion(goalId: Value(mvpGoalId), taskId: Value(t.id)),
    );
  }
  final allHabits = await db.select(db.habits).get();
  // MVP goal → a couple of supporting habits (journaling ✍️, reading 📚),
  // so its card shows linked habits alongside linked tasks.
  for (final h in allHabits.where((h) => h.emoji == '✍️' || h.emoji == '📚')) {
    await db.goalsDao.insertHabitLink(
      GoalHabitLinksCompanion(goalId: Value(mvpGoalId), habitId: Value(h.id)),
    );
  }
  // Exercise goal → every habit (streak count is computed live in the UI).
  for (final h in allHabits) {
    await db.goalsDao.insertHabitLink(
      GoalHabitLinksCompanion(goalId: Value(exerciseGoalId), habitId: Value(h.id)),
    );
  }
}

// ── Notes ─────────────────────────────────────────────────────────────────────

Future<void> _seedNotes(AppDatabase db, int lang) async {
  final id1 = await db.notesDao.insertNote(NotesCompanion(
    title:    Value(_s(['Product Roadmap thoughts','製品ロードマップ考察','Produktroadmap-Gedanken','제품 로드맵 생각','Réflexions roadmap produit','产品路线图想法','Reflexiones roadmap producto','Reflexões roadmap produto','प्रोडक्ट रोडमैप विचार','أفكار خارطة طريق المنتج','ప్రొడక్ట్ రోడ్‌మ్యాప్ ఆలోచనలు','Riflessioni sul roadmap prodotto','Gedachten over productroadmap','தயாரிப்பு ரோட்மேப் சிந்தனைகள்','ಉತ್ಪನ್ನ ರೋಡ್‌ಮ್ಯಾಪ್ ಆಲೋಚನೆಗಳು','പ്ര‌ൊ‌ഡ‌ക്ട് ‌റോ‌ഡ്‌മ‌ാ‌പ്പ് ‌ആ‌ലോ‌ച‌ന‌കൾ','उत्पाद रोडमॅप विचार','product roadmap vichaaro','পণ্য রোডম্যাপ চিন্তা'], lang)),
    body:     Value(_s(['3 key talking points for tomorrow. Need to address Q3 timeline concerns and budget reallocation…','明日の3つのキーポイント。Q3タイムラインと予算再配分が必要…','3 Gesprächspunkte für morgen. Q3-Zeitplan und Budget klären…','내일을 위한 3가지 핵심 포인트. Q3 타임라인 필요…','3 points clés pour demain. Aborder le calendrier Q3…','明天的3个关键谈话点。解决Q3时间线问题…','3 puntos clave para mañana. Abordar cronograma Q3…','3 pontos-chave para amanhã. Abordar cronograma Q3…','कल के लिए 3 मुख्य बिंदु। Q3 टाइमलाइन…','نقاط حوار رئيسية لغد. معالجة جدول Q3…','రేపటి కోసం 3 ముఖ్య అంశాలు. Q3 టైమ్‌లైన్ మరియు బడ్జెట్ పున:కేటాయింపు…','3 punti chiave per domani. Q3 timeline e riallocazione budget…','3 kernpunten voor morgen. Q3-tijdlijn en budget aanpakken…','நாளைக்கான 3 முக்கிய புள்ளிகள். Q3 காலக்கெடு மற்றும் பட்ஜெட்…','ನಾಳೆಗೆ 3 ಮುಖ್ಯ ಅಂಶಗಳು. Q3 ಟೈಮ್‌ಲೈನ್ ಮತ್ತು ಬಜೆಟ್…','ന‌ാ‌ളെ‌ക്ക് 3 ‌പ്ര‌ധാ‌ന ‌പോ‌യ‌ൻ്റ്. Q3 ‌ടൈ‌ം‌ലൈ‌ൻ…','उद्यासाठी 3 मुख्य मुद्दे. Q3 टाइमलाइन आणि बजेट…','kal maate 3 mukhy muddaa. Q3 timeline ane budget…','আগামীকালের ৩ মূল পয়েন্ট। Q3 টাইমলাইন ও বাজেট…'], lang)),
    isPinned: const Value(true),
    aiLabel:  const Value('✦ AI summary'),
    timeLabel: const Value('2h ago'),
  ));
  await db.notesDao.insertTag(NoteTagsCompanion(noteId: Value(id1), label: const Value('Q2'),           bgColorValue: const Value(0x237FBA00), fgColorValue: const Value(0xFF9FCD44), sortOrder: const Value(0)));
  await db.notesDao.insertTag(NoteTagsCompanion(noteId: Value(id1), label: Value(_s(['Meeting prep','ミーティング準備','Besprechungsvorbereitung','회의 준비','Préparation réunion','会议准备','Preparación reunión','Preparação reunião','मीटिंग प्रीप','تحضير الاجتماع','సమావేశ సన్నద్ధత','Preparazione riunione','Vergadervoorbereiding','கூட்ட தயாரிப்பு','ಸಭೆ ತಯಾರಿ','‌മീ‌റ്റിം‌ഗ് ‌ത‌യ്യ‌ാ‌റെ‌ടു‌പ്പ്','बैठकीची तयारी','meeting taiyari','মিটিং প্রস্তুতি'], lang)), bgColorValue: const Value(0x1F0A84FF), fgColorValue: const Value(0xFF409CFF), sortOrder: const Value(1)));
  await db.notesDao.insertTag(NoteTagsCompanion(noteId: Value(id1), label: const Value('⚡ Action items: 3'), bgColorValue: const Value(0x23FF6B6B), fgColorValue: const Value(0xFFFF8080), sortOrder: const Value(2)));

  final id2 = await db.notesDao.insertNote(NotesCompanion(
    title:    Value(_s(['Weekly review — Mar 22','週次レビュー — 3月22日','Wochenrückblick — 22. Mär','주간 리뷰 — 3월 22일','Bilan hebdomadaire — 22 mars','每周回顾 — 3月22日','Revisión semanal — 22 mar','Revisão semanal — 22 mar','साप्ताहिक समीक्षा — 22 मार्च','المراجعة الأسبوعية — 22 مارس','వారపు సమీక్ష — మార్చి 22','Revisione settimanale — 22 mar','Weekelijkse review — 22 mrt','வாராந்திர மதிப்பாய்வு — மார். 22','ವಾರ್ಷಿಕ ಪರಿಶೀಲನೆ — ಮಾ. 22','‌ആ‌ഴ്‌ച‌ വ‌ാ‌ര‌ അ‌വ‌ലോ‌ക‌ന‌ം — ‌മ‌ാ‌ർ. 22','साप्ताहिक आढावा — 22 मार्च','saaptahik review — Mar 22','সাপ্তাহিক পর্যালোচনা — মার্চ ২২'], lang)),
    body:     Value(_s(['Completed 80% Q2 this week. Missing: gym 2x and newsletter draft. Next week focus on deep work blocks…','今週のQ2完了率80%。未達成：ジム2回とニュースレター。来週は深い作業に集中…','Diese Woche 80% Q2 erledigt. Fehlend: 2x Fitnessstudio und Newsletter. Nächste Woche Deep Work…','이번 주 Q2 80% 완료. 미완료: 헬스 2회, 뉴스레터. 다음 주 깊은 작업 집중…','Complété 80% du Q2 cette semaine. Manquant : salle 2x et newsletter. Semaine prochaine : travail profond…','本周完成Q2的80%。缺失：健身房2次和新闻稿。下周专注于深度工作…','Completé 80% del Q2 esta semana. Pendiente: gimnasio 2x y newsletter. Próxima semana trabajo profundo…','Completei 80% do Q2 esta semana. Pendente: academia 2x e newsletter. Próxima semana trabalho profundo…','इस सप्ताह Q2 का 80% पूरा किया। छूटा: जिम 2 बार और न्यूज़लेटर। अगले सप्ताह डीप वर्क…','اكتملت 80% من Q2 هذا الأسبوع. المفقود: الصالة مرتين والنشرة. الأسبوع القادم التركيز على العمل العميق…','ఈ వారం Q2లో 80% పూర్తయింది. తప్పిపోయినది: జిమ్ 2 సార్లు మరియు న్యూస్‌లెటర్. తదుపరి వారం లోతైన పని…','Completato l\'80% del Q2 questa settimana. Mancante: palestra 2x e newsletter. Prossima settimana deep work…','80% van Q2 voltooid. Mist: sportschool 2x en nieuwsbrief. Volgende week diep werk…','இந்த வாரம் Q2ல் 80% முடிந்தது. விடுபட்டது: ஜிம் 2 முறை மற்றும் செய்திமடல். அடுத்த வாரம்…','ಈ ವಾರ Q2ರ 80% ಮುಗಿಸಿದೆ. ಕಳೆದುಕೊಂಡಿದ್ದು: ಜಿಮ್ 2 ಬಾರಿ. ಮುಂದಿನ ವಾರ ಆಳ ಕೆಲಸ…','‌ഈ ‌ആ‌ഴ്‌ച Q2 80% ‌പൂ‌ർ‌ത്തി. ‌ഇ‌ല്ലാ‌ത്ത‌ത്: ‌ജിം 2 ‌ത‌വ‌ണ. ‌അ‌ടു‌ത്ത ‌ആ‌ഴ്‌ച…','या आठवड्यात Q2 चे 80% पूर्ण. कमी: जिम 2x. पुढील आठवडा खोल काम…','aa athi maaNe Q2 no 80% puro. Chadyu nathi: gym 2x. Agaalthi athi maaNe…','এই সপ্তাহে Q2-এর ৮০% সম্পন্ন। মিস: জিম ২ বার। পরের সপ্তাহ গভীর কাজ…'], lang)),
    isPinned:  const Value(true),
    timeLabel: const Value('6d ago'),
  ));
  await db.notesDao.insertTag(NoteTagsCompanion(noteId: Value(id2), label: Value(_s(['Review','レビュー','Rückblick','리뷰','Bilan','回顾','Revisión','Revisão','समीक्षा','مراجعة','సమీక్ష','Revisione','Beoordeling','மதிப்பாய்வு','ಪರಿಶೀಲನೆ','‌അ‌വ‌ലോ‌ക‌നം','आढावा','review','পর্যালোচনা'], lang)), bgColorValue: const Value(0x1F0A84FF), fgColorValue: const Value(0xFF409CFF), sortOrder: const Value(0)));
  await db.notesDao.insertTag(NoteTagsCompanion(noteId: Value(id2), label: const Value('✦ AI scored: 7.8'), bgColorValue: const Value(0x237FBA00), fgColorValue: const Value(0xFF9FCD44), sortOrder: const Value(1)));

  await db.notesDao.insertNote(NotesCompanion(
    title:     Value(_s(['Book recommendations','本のおすすめ','Buchempfehlungen','책 추천','Recommandations de livres','书籍推荐','Recomendaciones de libros','Recomendações de livros','किताब की सिफारिशें','توصيات كتب','పుస్తక సూచనలు','Consigli di libri','Boekenaanbevelingen','புத்தக பரிந்துரைகள்','ಪುಸ್ತಕ ಶಿಫಾರಸುಗಳು','‌പു‌സ്‌ത‌ക ‌ശു‌പ‌ാ‌ർ‌ശ‌കൾ','पुस्तक शिफारसी','pustak bhalamaNa','বই সুপারিশ'], lang)),
    body:      Value(_s(['Deep Work, Atomic Habits, The 7 Habits — start with Deep Work this month','ディープ・ワーク、アトミックハビッツ、7つの習慣 — 今月はディープ・ワークから','Deep Work, Atomare Gewohnheiten, 7 Gewohnheiten — mit Deep Work beginnen','딥 워크, 아토믹 해빗, 7가지 습관 — 이번 달 딥 워크부터','Deep Work, Atomic Habits, 7 habitudes — commencer avec Deep Work','深度工作, 原子习惯, 7个习惯 — 本月从深度工作开始','Trabajo Profundo, Hábitos Atómicos, Los 7 Hábitos — empezar con Trabajo Profundo','Trabalho Profundo, Hábitos Atômicos, Os 7 Hábitos — começar com Trabalho Profundo','डीप वर्क, एटॉमिक हैबिट्स, 7 हैबिट्स — इस महीने डीप वर्क से शुरुआत','العمل العميق، العادات الذرية، العادات السبع — ابدأ بالعمل العميق','డీప్ వర్క్, అటామిక్ హ్యాబిట్స్, 7 అలవాట్లు — ఈ నెల డీప్ వర్క్‌తో మొదలుపెట్టండి','Deep Work, Abitudini Atomiche, Le 7 Abitudini — cominciare con Deep Work questo mese','Deep Work, Atomaire gewoonten, De 7 gewoonten — begin met Deep Work deze maand','டீப் வொர்க், அடாமிக் ஹாபிட்ஸ், 7 பழக்கங்கள் — இந்த மாதம் டீப் வொர்க்கிலிருந்து தொடங்கவும்','ಡೀಪ್ ವರ್ಕ್, ಅಟಾಮಿಕ್ ಹ್ಯಾಬಿಟ್ಸ್, 7 ಅಭ್ಯಾಸಗಳು — ಈ ತಿಂಗಳು ಡೀಪ್ ವರ್ಕ್‌ನಿಂದ ಪ್ರಾರಂಭ','Deep Work, Atomic Habits, 7 ‌ശീ‌ല‌ങ്ങൾ — ‌ഈ ‌മ‌ാ‌സം Deep Work ‌ആ‌ദ്യം','डीप वर्क, अॅटोमिक हॅबिट्स, 7 सवयी — या महिन्यात डीप वर्कपासून सुरुवात','Deep Work, Atomic Habits, 7 Tevo — aa mahine Deep Work thi sharu','ডিপ ওয়ার্ক, অ্যাটমিক হ্যাবিটস, ৭টি অভ্যাস — এই মাসে ডিপ ওয়ার্ক দিয়ে শুরু'], lang)),
    timeLabel: const Value('2d ago'),
  ));
  await db.notesDao.insertNote(NotesCompanion(
    title:     Value(_s(['Grocery list','買い物リスト','Einkaufsliste','장보기 목록','Liste de courses','购物清单','Lista de la compra','Lista de compras','किराने का सामान की सूची','قائمة البقالة','కిరాణా జాబితా','Lista della spesa','Boodschappenlijst','மளிகை பட்டியல்','ದಿನಸಿ ಪಟ್ಟಿ','‌ഭ‌ക്ഷ്യ ‌ലി‌സ്റ്റ്','किराणा यादी','kiraana saaman ni yaadi','মুদিখানার তালিকা'], lang)),
    body:      Value(_s(['Eggs, milk, olive oil, spinach, protein powder, almonds…','卵、牛乳、オリーブオイル、ほうれん草、プロテイン、アーモンド…','Eier, Milch, Olivenöl, Spinat, Proteinpulver, Mandeln…','계란, 우유, 올리브 오일, 시금치, 단백질 파우더, 아몬드…','Œufs, lait, huile d\'olive, épinards, protéines, amandes…','鸡蛋、牛奶、橄榄油、菠菜、蛋白粉、杏仁…','Huevos, leche, aceite de oliva, espinacas, proteína, almendras…','Ovos, leite, azeite, espinafre, proteína em pó, amêndoas…','अंडे, दूध, जैतून का तेल, पालक, प्रोटीन पाउडर, बादाम…','بيض، حليب، زيت زيتون، سبانخ، بروتين، لوز…','గుడ్లు, పాలు, ఆలివ్ నూనె, పాలకూర, ప్రోటీన్ పౌడర్, బాదం…','Uova, latte, olio d\'oliva, spinaci, proteine in polvere, mandorle…','Eieren, melk, olijfolie, spinazie, eiwitpoeder, amandelen…','முட்டைகள், பால், ஆலிவ் எண்ணெய், கீரை, புரத தூள், பாதாம்…','ಮೊಟ್ಟೆ, ಹಾಲು, ಆಲಿವ್ ಎಣ್ಣೆ, ಪಾಲಕ್, ಪ್ರೋಟೀನ್ ಪೌಡರ್, ಬಾದಾಮಿ…','‌മു‌ട്ട, ‌പ‌ാൽ, ‌ഒ‌ലി‌വ് ‌ഓ‌യ‌ൽ, ‌പ‌ാ‌ല‌ക്, ‌പ്രോ‌ട്ടീ‌ൻ ‌പൗ‌ഡ‌ർ, ‌ബ‌ദ‌ാം…','अंडी, दूध, ऑलिव्ह तेल, पालक, प्रोटीन पावडर, बदाम…','Anda, daadh, olive oil, palak, protein powder, badam…','ডিম, দুধ, অলিভ অয়েল, পালংশাক, প্রোটিন পাউডার, বাদাম…'], lang)),
    timeLabel: const Value('3d ago'),
  ));
}

// ── Calendar ──────────────────────────────────────────────────────────────────

Future<void> _seedCalendar(AppDatabase db, int lang) async {
  final events = [
    (
      title:   _s(['Morning journaling','朝のジャーナリング','Morgentagebuch','아침 저널링','Journal du matin','晨间日记','Diario matutino','Diário matinal','सुबह जर्नलिंग','التأمل الصباحي','ఉదయం జర్నలింగ్','Diario mattutino','Ochtenddagboek','காலை குறிப்பேடு','ಬೆಳಿಗ್ಗೆ ಜರ್ನಲಿಂಗ್','ര‌ാ‌വി‌ലെ ‌ജേ‌ർ‌ണ‌ലിം‌ഗ്','सकाळचे लेखन','savare ni diary','সকালের জার্নালিং'], lang),
      subtitle: '↻ Daily · 20 min',
      slot: '9 AM', color: 0xFF0A84FF, overdue: false, invite: false,
    ),
    (
      title:   _s(['Assignment submission','課題提出','Aufgabenabgabe','과제 제출','Soumission de devoir','作业提交','Entrega de tarea','Entrega de tarefa','असाइनमेंट जमा','تسليم المهمة','అసైన్‌మెంట్ సమర్పణ','Consegna compito','Opdracht inleveren','பணி சமர்ப்பணம்','ಕಾರ್ಯ ಸಲ್ಲಿಕೆ','‌അ‌സൈ‌ൻ‌മെ‌ൻ്റ് ‌സ‌മ‌ർ‌പ്പ‌ണം','असाइनमेंट सादरीकरण','assignment jama','অ্যাসাইনমেন্ট জমা'], lang),
      subtitle: '',
      slot: '10 AM', color: 0xFFFF3B30, overdue: true, invite: false,
    ),
    (
      title:   _s(['Q2 planning review','Q2計画レビュー','Q2-Planungsüberprüfung','Q2 계획 검토','Revue planification Q2','Q2规划审查','Revisión planificación Q2','Revisão planejamento Q2','Q2 योजना समीक्षा','مراجعة تخطيط Q2','Q2 ప్రణాళిక సమీక్ష','Revisione pianificazione Q2','Q2-planningsreview','Q2 திட்டமிடல் மதிப்பாய்வு','Q2 ಯೋಜನೆ ಪರಿಶೀಲನೆ','Q2 ‌ആ‌സൂ‌ത്ര‌ണ ‌അ‌വ‌ലോ‌ക‌നം','Q2 नियोजन आढावा','Q2 aayojana samiksha','Q2 পরিকল্পনা পর্যালোচনা'], lang),
      subtitle: '30 min · 6 people',
      slot: '11 AM', color: 0xFF34C759, overdue: false, invite: true,
    ),
    (
      title:   _s(['Design sync','デザイン同期','Design-Sync','디자인 싱크','Synchronisation design','设计同步','Sincronización de diseño','Sincronização de design','डिज़ाइन सिंक','مزامنة التصميم','డిజైన్ సింక్','Sincronizzazione design','Ontwerpsynchronisatie','வடிவமைப்பு ஒத்திசைவு','ವಿನ್ಯಾಸ ಸಿಂಕ್','‌ഡി‌സൈ‌ൻ ‌സിം‌ക്','डिझाइन सिंक','design sync','ডিজাইন সিঙ্ক'], lang),
      subtitle: '60 min · 3 people',
      slot: '2 PM', color: 0xFF0A84FF, overdue: false, invite: false,
    ),
    (
      title:   _s(['Design sync','デザイン同期','Design-Sync','디자인 싱크','Synchronisation design','设计同步','Sincronización de diseño','Sincronização de design','डिज़ाइन सिंक','مزامنة التصميم','డిజైన్ సింక్','Sincronizzazione design','Ontwerpsynchronisatie','வடிவமைப்பு ஒத்திசைவு','ವಿನ್ಯಾಸ ಸಿಂಕ್','‌ഡി‌സൈ‌ൻ ‌സിം‌ക്','डिझाइन सिंक','design sync','ডিজাইন সিঙ্ক'], lang),
      subtitle: '60 min · 3 people',
      slot: '2 PM', color: 0xFF34C759, overdue: false, invite: true,
    ),
    (
      title:   _s(['Product roadmap research','製品ロードマップリサーチ','Produktroadmap-Recherche','제품 로드맵 연구','Recherche roadmap produit','产品路线图研究','Investigación roadmap producto','Pesquisa roadmap produto','प्रोडक्ट रोडमैप रिसर्च','بحث خارطة طريق المنتج','ప్రొడక్ట్ రోడ్‌మ్యాప్ పరిశోధన','Ricerca roadmap prodotto','Productroadmaponderzoek','தயாரிப்பு ரோட்மேப் ஆராய்ச்சி','ಉತ್ಪನ್ನ ರೋಡ್‌ಮ್ಯಾಪ್ ಸಂಶೋಧನೆ','‌പ്ര‌ൊ‌ഡ‌ക്ട് ‌റോ‌ഡ്‌മ‌ാ‌പ്പ് ‌ഗ‌വേ‌ഷ‌ണം','उत्पाद रोडमॅप संशोधन','product roadmap sanshodhan','পণ্য রোডম্যাপ গবেষণা'], lang),
      subtitle: 'Q2 · 45 min',
      slot: '4 PM', color: 0xFF0A84FF, overdue: false, invite: false,
    ),
  ];

  for (final e in events) {
    await db.calendarDao.insertEvent(CalendarEventsCompanion(
      title:     Value(e.title),
      subtitle:  Value(e.subtitle),
      timeSlot:  Value(e.slot),
      colorValue: Value(e.color),
      isOverdue: Value(e.overdue),
      isInvite:  Value(e.invite),
    ));
  }
}
