// ignore_for_file: lines_longer_than_80_chars
// Index order (11 languages) — global build, no Indian-language group
// (see Kaal for that; TaskEra targets the global market):
// 0=en 1=ja 2=de 3=ko 4=fr 5=zh 6=es 7=pt 8=it 9=nl 10=ar

class AppStrings {
  final int _i;
  const AppStrings(int langIdx) : _i = langIdx;

  int get langIdx => _i;

  String _t(List<String> t) => t[_i < t.length ? _i : 0];

  // ── Navigation ─────────────────────────────────────────────────────────────
  String get focus    => _t(['Focus','フォーカス','Fokus','집중','Focus','专注','Enfoque','Foco','Focus','Focus','التركيز']);
  String get tasks    => _t(['Tasks','タスク','Aufgaben','작업','Tâches','任务','Tareas','Tarefas','Attività','Taken','المهام']);
  String get habits   => _t(['Habits','習慣','Gewohnheiten','습관','Habitudes','习惯','Hábitos','Hábitos','Abitudini','Gewoonten','العادات']);
  String get calendar => _t(['Calendar','カレンダー','Kalender','캘린더','Calendrier','日历','Calendario','Calendário','Calendario','Kalender','التقويم']);
  String get inbox    => _t(['Inbox','受信トレイ','Posteingang','받은함','Boîte de réception','收件箱','Bandeja','Caixa de entrada','Posta in arrivo','Inbox','صندوق الوارد']);
  String get notes    => _t(['Notes','ノート','Notizen','노트','Notes','笔记','Notas','Notas','Note','Notities','الملاحظات']);
  String get settings => _t(['Settings','設定','Einstellungen','설정','Paramètres','设置','Ajustes','Configurações','Impostazioni','Instellingen','الإعدادات']);
  String get goals    => _t(['Goals','目標','Ziele','목표','Objectifs','目标','Metas','Metas','Obiettivi','Doelen','الأهداف']);

  // ── Common actions ──────────────────────────────────────────────────────────
  String get save     => _t(['Save','保存','Speichern','저장','Enregistrer','保存','Guardar','Salvar','Salva','Opslaan','حفظ']);
  String get cancel   => _t(['Cancel','キャンセル','Abbrechen','취소','Annuler','取消','Cancelar','Cancelar','Annulla','Annuleren','إلغاء']);
  String get delete   => _t(['Delete','削除','Löschen','삭제','Supprimer','删除','Eliminar','Excluir','Elimina','Verwijderen','حذف']);
  String get edit     => _t(['Edit','編集','Bearbeiten','편집','Modifier','编辑','Editar','Editar','Modifica','Bewerken','تعديل']);
  String get add      => _t(['Add','追加','Hinzufügen','추가','Ajouter','添加','Agregar','Adicionar','Aggiungi','Toevoegen','إضافة']);
  String get done     => _t(['Done','完了','Fertig','완료','Terminé','完成','Listo','Pronto','Fatto','Klaar','تم']);

  // ── Confirmation dialog ─────────────────────────────────────────────────────
  String get confirmDeleteTitle => _t(['Delete?','削除？','Löschen?','삭제?','Supprimer ?','删除？','¿Eliminar?','Excluir?','Eliminare?','Verwijderen?','حذف؟']);
  String get confirmDeleteMsg   => _t(['This cannot be undone.','これは元に戻せません。','Dies kann nicht rückgängig gemacht werden.','이 작업은 취소할 수 없습니다.','Cela ne peut pas être annulé.','此操作无法撤销。','Esto no se puede deshacer.','Isso não pode ser desfeito.','Questa azione non può essere annullata.','Dit kan niet ongedaan worden gemaakt.','لا يمكن التراجع عن هذا.']);
  String get yes      => _t(['Yes','はい','Ja','예','Oui','是','Sí','Sim','Sì','Ja','نعم']);
  String get no       => _t(['No','いいえ','Nein','아니요','Non','否','No','Não','No','Nee','لا']);

  // ── Time periods ────────────────────────────────────────────────────────────
  String get today    => _t(['Today','今日','Heute','오늘',"Aujourd'hui",'今天','Hoy','Hoje','Oggi','Vandaag','اليوم']);
  String get week     => _t(['Week','週','Woche','주','Semaine','周','Semana','Semana','Settimana','Week','أسبوع']);
  String get month    => _t(['Month','月','Monat','월','Mois','月','Mes','Mês','Mese','Maand','شهر']);
  String get year     => _t(['Year','年','Jahr','연','Année','年','Año','Ano','Anno','Jaar','سنة']);
  String get allTime  => _t(['All time','全期間','Alle Zeiten','전체 기간','Depuis toujours','所有时间','Todo el tiempo','Todo o tempo','Da sempre','Altijd','طوال الوقت']);

  // ── Stats labels ────────────────────────────────────────────────────────────
  String get streak       => _t(['Streak','連続記録','Serie','연속','Série','连续','Racha','Sequência','Serie','Reeks','تتالي']);
  String get completion   => _t(['Completion','完了率','Abschluss','완료율','Achèvement','完成率','Completado','Conclusão','Completamento','Voltooiing','الإنجاز']);
  String get bestDay      => _t(['Best day','最良の日','Bester Tag','최고의 날','Meilleur jour','最佳日','Mejor día','Melhor dia','Giorno migliore','Beste dag','أفضل يوم']);
  String get perfectDays  => _t(['Perfect days','完璧な日','Perfekte Tage','완벽한 날','Jours parfaits','完美天数','Días perfectos','Dias perfeitos','Giorni perfetti','Perfecte dagen','أيام مثالية']);

  // ── Time of day ─────────────────────────────────────────────────────────────
  String get morning   => _t(['Morning','朝','Morgen','아침','Matin','早晨','Mañana','Manhã','Mattina','Ochtend','صباح']);
  String get afternoon => _t(['Afternoon','午後','Nachmittag','오후','Après-midi','下午','Tarde','Tarde','Pomeriggio','Middag','ظهر']);
  String get evening   => _t(['Evening','夕方','Abend','저녁','Soir','傍晚','Tarde','Tarde','Sera','Avond','مساء']);
  String get night     => _t(['Night','夜','Nacht','밤','Nuit','夜晚','Noche','Noite','Notte','Nacht','ليل']);

  // ── Screen sections ─────────────────────────────────────────────────────────
  String get quadrants  => _t(['Quadrants','四象限','Quadranten','사분면','Quadrants','四象限','Cuadrantes','Quadrantes','Quadranti','Kwadranten','المربعات']);
  String get brainDump  => _t(['Brain Dump','ブレインダンプ','Gedanken entleeren','브레인 덤프','Vider les pensées','头脑清空','Volcado mental','Despejo mental','Scarico mentale','Hersendump','إفراغ الذهن']);
  String get addTask    => _t(['Add task','タスクを追加','Aufgabe hinzufügen','작업 추가','Ajouter une tâche','添加任务','Agregar tarea','Adicionar tarefa','Aggiungi attività','Taak toevoegen','إضافة مهمة']);
  String get addHabit   => _t(['New habit','新しい習慣','Neue Gewohnheit','새 습관','Nouvelle habitude','新习惯','Nuevo hábito','Novo hábito','Nuova abitudine','Nieuwe gewoonte','عادة جديدة']);
  String get addNote    => _t(['New note','新しいノート','Neue Notiz','새 메모','Nouvelle note','新笔记','Nueva nota','Nova nota','Nuova nota','Nieuwe notitie','ملاحظة جديدة']);
  String get addGoal    => _t(['New goal','新しい目標','Neues Ziel','새 목표','Nouvel objectif','新目标','Nueva meta','Nova meta','Nuovo obiettivo','Nieuw doel','هدف جديد']);

  // ── Empty states ────────────────────────────────────────────────────────────
  String get noTasks  => _t(['No tasks yet','タスクはまだありません','Noch keine Aufgaben','아직 작업 없음','Pas encore de tâches','还没有任务','Sin tareas aún','Sem tarefas ainda','Nessuna attività ancora','Nog geen taken','لا توجد مهام بعد']);
  String get noHabits => _t(['No habits yet','習慣はまだありません','Noch keine Gewohnheiten','아직 습관 없음',"Pas encore d'habitudes",'还没有习惯','Sin hábitos aún','Sem hábitos ainda','Nessuna abitudine ancora','Nog geen gewoonten','لا توجد عادات بعد']);
  String get noNotes  => _t(['No notes yet','ノートはまだありません','Noch keine Notizen','아직 메모 없음',"Pas encore de notes",'还没有笔记','Sin notas aún','Sem notas ainda','Nessuna nota ancora','Nog geen notities','لا توجد ملاحظات بعد']);
  String get noGoals  => _t(['No goals yet','目標はまだありません','Noch keine Ziele','아직 목표 없음',"Pas encore d'objectifs",'还没有目标','Sin metas aún','Sem metas ainda','Nessun obiettivo ancora','Nog geen doelen','لا توجد أهداف بعد']);

  // ── Onboarding ──────────────────────────────────────────────────────────────
  String get chooseLanguage => _t(['Choose your language','言語を選択','Sprache wählen','언어 선택','Choisissez votre langue','选择语言','Elige tu idioma','Escolha o idioma','Scegli la lingua','Kies je taal','اختر لغتك']);
  String get continueLabel  => _t(['Continue →','続ける →','Weiter →','계속 →','Continuer →','继续 →','Continuar →','Continuar →','Continua →','Doorgaan →','متابعة →']);

  // ── Settings section titles ─────────────────────────────────────────────────
  String get display            => _t(['Display','表示','Anzeige','화면','Affichage','显示','Pantalla','Exibição','Schermo','Weergave','العرض']);
  String get tabsLabel          => _t(['Tabs','タブ','Tabs','탭','Onglets','标签页','Pestañas','Abas','Schede','Tabbladen','علامات التبويب']);
  String get calendarAndInbox   => _t(['Calendar & Inbox','カレンダー & 受信','Kalender & Posteingang','캘린더 & 받은함','Calendrier & Boîte','日历 & 收件箱','Calendario & Bandeja','Calendário & Caixa','Calendario & Posta','Kalender & Inbox','التقويم والبريد']);
  String get featuresAndSmart   => _t(['Features & Smart','機能 & スマート','Funktionen & Smart','기능 & 스마트','Fonctions & Smart','功能 & 智能','Funciones & Smart','Recursos & Smart','Funzioni & Smart','Functies & Smart','الميزات والذكاء']);
  String get integrationsLabel  => _t(['Integrations','統合','Integrationen','통합','Intégrations','集成','Integraciones','Integrações','Integrazioni','Integraties','التكاملات']);
  String get syncAndData        => _t(['Sync & Data','同期 & データ','Sync & Daten','동기화 & 데이터','Sync & Données','同步 & 数据','Sincronización & Datos','Sincronização & Dados','Sincronizzazione & Dati','Synchronisatie & Gegevens','المزامنة والبيانات']);
  String get notificationsLabel => _t(['Notifications','通知','Benachrichtigungen','알림','Notifications','通知','Notificaciones','Notificações','Notifiche','Meldingen','الإشعارات']);

  // ── Settings subsection labels ──────────────────────────────────────────────
  String get languageLabel      => _t(['Language','言語','Sprache','언어','Langue','语言','Idioma','Idioma','Lingua','Taal','اللغة']);
  String get themeAndAppearance => _t(['Theme & Appearance','テーマと外観','Thema & Aussehen','테마 & 외관','Thème & Apparence','主题 & 外观','Tema & Apariencia','Tema & Aparência','Tema & Aspetto','Thema & Uiterlijk','الثيم والمظهر']);
  String get typography         => _t(['Typography','タイポグラフィ','Typografie','타이포그래피','Typographie','排版','Tipografía','Tipografia','Tipografia','Typografie','الخطوط']);
  String get tasksView          => _t(['Tasks view','タスク表示','Aufgaben-Ansicht','작업 보기','Vue des tâches','任务视图','Vista de tareas','Visualização de tarefas','Vista attività','Taken weergave','عرض المهام']);
  String get accentColour       => _t(['Accent colour','アクセントカラー','Akzentfarbe','강조 색상',"Couleur d'accent",'强调色','Color de acento','Cor de destaque','Colore accento','Accentkleur','لون التمييز']);
  String get fontStyle          => _t(['Font style','フォントスタイル','Schriftstil','글꼴 스타일','Style de police','字体样式','Estilo de fuente','Estilo de fonte','Stile carattere','Lettertype stijl','نمط الخط']);
  String get fontSizeLabel      => _t(['Font size','フォントサイズ','Schriftgröße','글꼴 크기','Taille de police','字体大小','Tamaño de fuente','Tamanho da fonte','Dimensione carattere','Lettergrootte','حجم الخط']);
  String get lineSpacing        => _t(['Line spacing','行間','Zeilenabstand','줄 간격','Interligne','行距','Espaciado de línea','Espaçamento de linha','Spaziatura riga','Regelafstand','تباعد الأسطر']);
  String get layoutLabel        => _t(['Layout','レイアウト','Layout','레이아웃','Disposition','布局','Diseño','Layout','Layout','Indeling','التخطيط']);
  String get quadrantNames      => _t(['Quadrant names','象限名','Quadrantennamen','사분면 이름','Noms des quadrants','象限名称','Nombres de cuadrantes','Nomes dos quadrantes','Nomi quadranti','Kwadrantnamen','أسماء الأقسام']);
  String get quadBgColors       => 'Quad background colors';
  String get numberFontStyle    => 'Number style';

  // ── Focus dashboard ─────────────────────────────────────────────────────────
  String get doThisNow          => _t(['DO THIS NOW','今すぐやれ','JETZT TUN','지금 하세요','FAITES CECI','现在就做','HAZ ESTO AHORA','FAÇA AGORA','FAI ORA','DOE DIT NU','افعل الآن']);
  String get noTasksDueToday    => _t(['No tasks due today','今日の期限タスクなし','Heute keine Aufgaben','오늘 마감 작업 없음',"Pas de tâches aujourd'hui",'今天没有到期任务','Sin tareas para hoy','Nenhuma tarefa para hoje','Nessuna attività per oggi','Geen taken voor vandaag','لا مهام اليوم']);
  String get noGoalsTapAdd      => _t(['No goals yet — tap to add','目標なし — タップして追加','Noch keine Ziele — tippen','목표 없음 — 탭하여 추가',"Pas d'objectifs — appuyez",'还没有目标 — 点击添加','Sin metas — toca para añadir','Sem metas — toque para adicionar','Nessun obiettivo — tocca','Geen doelen — tik om toe te voegen','لا أهداف — اضغط للإضافة']);
  String get active             => _t(['Active','アクティブ','Aktiv','활성','Actif','活跃','Activo','Ativo','Attivo','Actief','نشط']);
  String get overdue            => _t(['Overdue','期限超過','Überfällig','기한 초과','En retard','逾期','Vencido','Atrasado','In ritardo','Te laat','متأخر']);
  String get focusToday         => _t(['Focus today','今日フォーカス','Heute fokussieren','오늘 집중','Focus du jour','今日专注','Enfoque hoy','Foco hoje','Focus oggi','Focus vandaag','ركز اليوم']);
  String get skip               => _t(['Skip','スキップ','Überspringen','건너뛰기','Passer','跳过','Saltar','Pular','Salta','Overslaan','تخطي']);
  String get startNow           => _t(['Start now','今すぐ開始','Jetzt starten','지금 시작','Commencer','现在开始','Empezar','Começar','Inizia','Nu starten','ابدأ الآن']);
  String get viewAll            => _t(['View all','すべて見る','Alle ansehen','전체 보기','Voir tout','查看全部','Ver todo','Ver tudo','Vedi tutto','Alles zien','عرض الكل']);
  String get resume             => _t(['Resume','再開','Fortsetzen','재개','Reprendre','继续','Reanudar','Retomar','Riprendi','Hervatten','استئناف']);
  String get pauseLabel         => _t(['Pause','一時停止','Pausieren','일시정지','Pause','暂停','Pausar','Pausar','Pausa','Pauzeren','إيقاف مؤقت']);
  String get undo               => _t(['Undo','元に戻す','Rückgängig','실행 취소','Annuler','撤销','Deshacer','Desfazer','Annulla','Ongedaan maken','تراجع']);
  String get doNow              => _t(['Do Now','今やる','Jetzt tun','지금 하기','À faire','立即做','Hacer ya','Fazer já','Fai ora','Nu doen','افعل الآن']);
  String get scheduleLabel      => _t(['Schedule','スケジュール','Planen','일정','Planifier','安排','Programar','Agendar','Pianifica','Plannen','جدول']);
  String get delegate           => _t(['Delegate','委任','Delegieren','위임','Déléguer','委派','Delegar','Delegar','Delega','Delegeren','فوض']);
  String get eliminate          => _t(['Eliminate','排除','Eliminieren','제거','Éliminer','消除','Eliminar','Eliminar','Elimina','Elimineren','احذف']);

  // ── Common UI labels ────────────────────────────────────────────────────────
  String get seeAll     => _t(['See all','すべて見る','Alle sehen','전체 보기','Voir tout','查看全部','Ver todo','Ver tudo','Vedi tutto','Alles zien','عرض الكل']);
  String get addNew     => _t(['Add new','新規追加','Neu hinzufügen','새로 추가','Ajouter nouveau','新增','Agregar nuevo','Adicionar novo','Aggiungi nuovo','Nieuw toevoegen','إضافة جديد']);
  String get myChecklists => _t(['MY CHECKLISTS','マイチェックリスト','MEINE CHECKLISTEN','내 체크리스트','MES LISTES','我的清单','MIS LISTAS','MINHAS LISTAS','LE MIE LISTE','MIJN LIJSTEN','قوائمي']);
  String get moveTo     => _t(['Move to','移動','Verschieben nach','이동','Déplacer vers','移动到','Mover a','Mover para','Sposta a','Verplaats naar','نقل إلى']);
  String get filter     => _t(['Filter','フィルター','Filter','필터','Filtrer','筛选','Filtrar','Filtrar','Filtra','Filteren','تصفية']);
  String get search     => _t(['Search','検索','Suchen','검색','Rechercher','搜索','Buscar','Pesquisar','Cerca','Zoeken','بحث']);
  String get upcoming   => _t(['Upcoming','近日予定','Bevorstehend','다가오는','À venir','即将到来','Próximo','Próximo','In arrivo','Aankomend','القادم']);
  String get recurring  => _t(['Recurring','繰り返し','Wiederkehrend','반복','Récurrent','重复','Recurrente','Recorrente','Ricorrente','Terugkerend','متكرر']);
  String get profile    => _t(['Profile','プロフィール','Profil','프로필','Profil','档案','Perfil','Perfil','Profilo','Profiel','الملف الشخصي']);
  String get connected  => _t(['Connected','接続済み','Verbunden','연결됨','Connecté','已连接','Conectado','Conectado','Connesso','Verbonden','متصل']);
  String get disconnect => _t(['Disconnect','切断','Trennen','연결 해제','Déconnecter','断开','Desconectar','Desconectar','Disconnetti','Verbreken','قطع الاتصال']);
  String get connect    => _t(['Connect','接続','Verbinden','연결','Connecter','连接','Conectar','Conectar','Connetti','Verbinden','اتصال']);

  // ── Goal & calendar strings ─────────────────────────────────────────────────
  String get nothingScheduled  => _t(['Nothing scheduled','予定なし','Nichts geplant','일정 없음','Rien prévu','无安排','Sin programar','Nada agendado','Niente pianificato','Niets gepland','لا يوجد جدول']);
  String get deleteGoal        => _t(['Delete goal','目標を削除','Ziel löschen','목표 삭제','Supprimer le but','删除目标','Eliminar meta','Excluir meta','Elimina obiettivo','Doel verwijderen','حذف الهدف']);
  String get overallProgress   => _t(['Overall progress','全体的な進捗','Gesamtfortschritt','전체 진행률','Progression globale','总体进度','Progreso general','Progresso geral','Progresso complessivo','Algehele voortgang','التقدم الكلي']);
  String get addMilestone      => _t(['Add milestone','マイルストーン追加','Meilenstein hinzufügen','이정표 추가','Ajouter jalon','添加里程碑','Agregar hito','Adicionar marco','Aggiungi traguardo','Mijlpaal toevoegen','إضافة مرحلة']);
  String get linkedTasks       => _t(['Linked tasks','関連タスク','Verknüpfte Aufgaben','연결된 작업','Tâches liées','关联任务','Tareas vinculadas','Tarefas vinculadas','Attività collegate','Gekoppelde taken','المهام المرتبطة']);
  String get linkTask          => _t(['Link task','タスクをリンク','Aufgabe verknüpfen','작업 연결','Lier tâche','链接任务','Vincular tarea','Vincular tarefa','Collega attività','Taak koppelen','ربط مهمة']);
  String get supportingHabits  => _t(['Supporting habits','サポート習慣','Unterstützende Gewohnheiten','지원 습관','Habitudes liées','关联习惯','Hábitos vinculados','Hábitos vinculados','Abitudini collegate','Ondersteunende gewoonten','العادات الداعمة']);
  String get linkHabit         => _t(['Link habit','習慣をリンク','Gewohnheit verknüpfen','습관 연결','Lier habitude','链接习惯','Vincular hábito','Vincular hábito','Collega abitudine','Gewoonte koppelen','ربط عادة']);

  /// Dynamic goal metadata: "Linked tasks · N" (N = number of linked tasks).
  String linkedTasksCount(int n) => '$linkedTasks · $n';

  /// Dynamic goal metadata: "Linked habits · n/total streaks this week"
  /// (n = linked habits with an active streak, total = linked habits).
  String linkedHabitsStreaks(int n, int total) {
    const t = [
      'Linked habits · {n}/{t} streaks this week',            // en
      'リンク習慣 · 今週 {n}/{t} 連続',                          // ja
      'Verknüpfte Gewohnheiten · {n}/{t} Serien',             // de
      '연결된 습관 · 이번 주 {n}/{t} 연속',                      // ko
      'Habitudes liées · {n}/{t} séries cette semaine',       // fr
      '关联习惯 · 本周 {n}/{t} 连续',                            // zh
      'Hábitos vinculados · {n}/{t} rachas esta semana',      // es
      'Hábitos vinculados · {n}/{t} sequências',              // pt
      'Abitudini collegate · {n}/{t} serie questa settimana', // it
      'Gekoppelde gewoonten · {n}/{t} reeksen deze week',     // nl
      'العادات المرتبطة · {n}/{t} تسلسلات هذا الأسبوع',          // ar
      'लिंक्ड हैबिट्स · इस सप्ताह {n}/{t} स्ट्रीक',                 // hi
      'అనుసంధానిత అలవాట్లు · ఈ వారం {n}/{t} స్ట్రీక్స్',           // te
      'இணைந்த பழக்கங்கள் · இந்த வாரம் {n}/{t}',                  // ta
      'ಸಂಪರ್ಕಿತ ಅಭ್ಯಾಸಗಳು · ಈ ವಾರ {n}/{t}',                     // kn
      'ബന്ധിപ്പിച്ച ശീലങ്ങൾ · ഈ ആഴ്ച {n}/{t}',                  // ml
      'लिंक केलेल्या सवयी · या आठवड्यात {n}/{t}',                 // mr
      'jodeyli tevo · aa athi maaNe {n}/{t}',                 // gu
      'সংযুক্ত অভ্যাস · এই সপ্তাহে {n}/{t} স্ট্রিক',              // bn
    ];
    final s = t[_i < t.length ? _i : 0];
    return s.replaceAll('{n}', '$n').replaceAll('{t}', '$total');
  }

  // ── Calendar strings ────────────────────────────────────────────────────────
  String get connections       => _t(['Connections','つながり','Verbindungen','연결','Connexions','连接','Conexiones','Conexões','Connessioni','Verbindingen','اتصالات']);
  String get editEvent         => _t(['Edit event','イベント編集','Ereignis bearbeiten','이벤트 편집','Modifier l\'événement','编辑事件','Editar evento','Editar evento','Modifica evento','Evenement bewerken','تعديل الحدث']);
  String get deleteEvent       => _t(['Delete event','イベント削除','Ereignis löschen','이벤트 삭제','Supprimer l\'événement','删除事件','Eliminar evento','Excluir evento','Elimina evento','Evenement verwijderen','حذف الحدث']);
  String get moveIt            => _t(['Move it','移動する','Verschieben','이동','Déplacer','移动','Mover','Mover','Sposta','Verplaats','انقل']);
  String get dismiss           => _t(['Dismiss','解除','Ablehnen','무시','Ignorer','忽略','Descartar','Descartar','Ignora','Negeren','تجاهل']);
  String get calendarSync      => _t(['Calendar sync','カレンダー同期','Kalender synchronisieren','달력 동기화','Synchronisation agenda','日历同步','Sincronización de calendario','Sincronização de calendário','Sincronizzazione calendario','Kalender synchroniseren','مزامنة التقويم']);
  String get syncDirection     => _t(['Sync direction','同期方向','Synchronisierungsrichtung','동기화 방향','Direction sync','同步方向','Dirección de sincronización','Direção de sincronização','Direzione sincronizzazione','Synchronisatierichting','اتجاه المزامنة']);

  // ── Settings toggle labels ──────────────────────────────────────────────────
  String get habitsTracker     => _t(['Habits tracker','習慣トラッカー','Gewohnheitstracker','습관 추적기','Suivi des habitudes','习惯追踪','Rastreador de hábitos','Rastreador de hábitos','Tracker abitudini','Gewoonten tracker','متتبع العادات']);
  String get calendarTab       => _t(['Calendar tab','カレンダータブ','Kalender-Tab','달력 탭','Onglet agenda','日历标签','Pestaña calendario','Aba calendário','Scheda calendario','Kalender tab','علامة التقويم']);
  String get notesTab          => _t(['Notes tab','ノートタブ','Notizen-Tab','메모 탭','Onglet notes','笔记标签','Pestaña notas','Aba notas','Scheda note','Notities tab','علامة الملاحظات']);
  String get inboxLabel        => _t(['Inbox','受信トレイ','Posteingang','받은함','Boîte de réception','收件箱','Bandeja de entrada','Caixa de entrada','Posta in arrivo','Inbox','صندوق الوارد']);
  String get showMyChecklists  => _t(['Show my checklists','チェックリストを表示','Meine Listen anzeigen','내 체크리스트 표시','Afficher mes listes','显示我的清单','Mostrar mis listas','Mostrar minhas listas','Mostra le mie liste','Mijn lijsten tonen','عرض قوائمي']);
  String get scoreRec          => _t(['Score-based recommendation','スコア推薦','Bewertungsempfehlung','점수 기반 추천','Recommandation par score','基于分数的推荐','Recomendación por puntuación','Recomendação por pontuação','Raccomandazione a punteggio','Score aanbeveling','توصية بالنقاط']);
  String get quoteSplash       => _t(['Quote splash on open','起動時に名言','Zitat beim Öffnen','열 때 명언','Citation au démarrage','启动时名言','Cita al abrir','Citação ao abrir','Citazione all\'apertura','Citaat bij opening','اقتباس عند الفتح']);
  String get eodReflect        => _t(['EOD reflection prompt','終業振り返り','Tagesabschluss','하루 마감 성찰','Bilan fin de journée','每日反思','Reflexión fin de día','Reflexão fim do dia','Riflessione fine giornata','Dagelijkse reflectie','تأمل نهاية اليوم']);
  String get eodReflectTime    => _t(['Reflection time','振り返りの時刻','Zeit für Rückblick','성찰 시간','Heure du bilan','反思时间','Hora de reflexión','Hora de reflexão','Ora della riflessione','Reflectietijd','وقت التأمل']);
  String get peakCard          => _t(['Peak card','ピークカード','Peak-Karte','피크 카드','Carte pic','峰值卡片','Tarjeta pico','Cartão pico','Scheda picco','Piekkaart','بطاقة الذروة']);
  String get brainDumpCard     => _t(['Brain Dump card','ブレインダンプカード','Gedanken-Karte','브레인 덤프 카드','Carte vider les pensées','头脑清空卡片','Tarjeta volcado mental','Cartão despejo mental','Scheda scarico mentale','Hersendump kaart','بطاقة إفراغ الذهن']);
  String get q1UrgentAlerts    => _t(['Q1 urgent alerts','Q1緊急アラート','Q1 dringende Meldungen','Q1 긴급 알림','Q1 alertes urgentes','Q1紧急提醒','Q1 alertas urgentes','Q1 alertas urgentes','Q1 avvisi urgenti','Q1 urgente meldingen','Q1 تنبيهات عاجلة']);
  String get q2DailyNudge      => _t(['Q2 daily nudge','Q2毎日のナッジ','Q2 tägliche Erinnerung','Q2 일일 알림','Q2 rappel quotidien','Q2每日提醒','Q2 recordatorio diario','Q2 lembrete diário','Q2 promemoria quotidiano','Q2 dagelijks duwtje','Q2 تذكير يومي']);
  String get taskReminders     => _t(['Task reminders','タスクリマインダー','Aufgaben-Erinnerungen','작업 알림','Rappels de tâches','任务提醒','Recordatorios de tareas','Lembretes de tarefas','Promemoria attività','Taakherinneringen','تذكيرات المهام']);
  String get q1OverloadWarning => _t(['Q1 overload warning','Q1過負荷警告','Q1 Überlastungswarnung','Q1 과부하 경고','Q1 surcharge','Q1超载警告','Q1 advertencia sobrecarga','Q1 aviso de sobrecarga','Q1 avviso sovraccarico','Q1 overbelasting','Q1 تحذير الحمل الزائد']);
  String get q2NeglectNudge    => _t(['Q2 neglect nudge','Q2放置通知','Q2 Vernachlässigung','Q2 방치 알림','Q2 rappel négligence','Q2遗忘提醒','Q2 descuido','Q2 negligência','Q2 trascuratezza','Q2 verwaarlozing','Q2 تذكير الإهمال']);
  String get gmailSync         => _t(['Gmail sync','Gmail同期','Gmail-Synchronisierung','Gmail 동기화','Sync Gmail','Gmail同步','Sincronización Gmail','Sincronização Gmail','Sincronizzazione Gmail','Gmail synchroniseren','مزامنة Gmail']);
  String get suggestTasksInbox => _t(['Suggest tasks from inbox','受信からタスク提案','Aufgaben aus Posteingang','받은함에서 작업 제안','Suggérer depuis boîte','从收件箱建议任务','Sugerir desde bandeja','Sugerir do e-mail','Suggerisci dalla posta','Stel taken voor uit inbox','اقتراح المهام من البريد']);
  String get cloudSync         => _t(['Cloud sync','クラウド同期','Cloud-Synchronisierung','클라우드 동기화','Sync cloud','云端同步','Sincronización en la nube','Sincronização na nuvem','Sincronizzazione cloud','Cloud synchronisatie','مزامنة السحابة']);
  String get activityLog       => _t(['Activity Log','アクティビティログ','Aktivitätsprotokoll','활동 로그','Journal d\'activité','活动日志','Registro de actividad','Registro de atividades','Registro attività','Activiteitenlog','سجل النشاط']);

  // ── Habits & goals screens ──────────────────────────────────────────────────
  String get achievements      => _t(['Achievements','実績','Erfolge','업적','Réalisations','成就','Logros','Conquistas','Traguardi','Prestaties','الإنجازات']);
  String get deleteHabit       => _t(['Delete habit','習慣を削除','Gewohnheit löschen','습관 삭제','Supprimer l\'habitude','删除习惯','Eliminar hábito','Excluir hábito','Elimina abitudine','Gewoonte verwijderen','حذف العادة']);
  String get linkTasksToGoal   => _t(['Link tasks to goal','目標にタスクをリンク','Aufgaben verknüpfen','목표에 작업 연결','Lier tâches au but','链接任务到目标','Vincular tareas a la meta','Vincular tarefas à meta','Collega attività all\'obiettivo','Taken aan doel koppelen','ربط المهام بالهدف']);
  String get noActiveTasksFound => _t(['No active tasks found.','アクティブなタスクなし','Keine aktiven Aufgaben','활성 작업 없음','Aucune tâche active','未找到活动任务','No hay tareas activas','Nenhuma tarefa ativa','Nessuna attività attiva','Geen actieve taken','لا توجد مهام نشطة']);
  String get linkHabitsToGoal  => _t(['Link habits to goal','目標に習慣をリンク','Gewohnheiten verknüpfen','목표에 습관 연결','Lier habitudes au but','链接习惯到目标','Vincular hábitos a la meta','Vincular hábitos à meta','Collega abitudini all\'obiettivo','Gewoonten aan doel koppelen','ربط العادات بالهدف']);
  String get noHabitsFound     => _t(['No habits found.','習慣が見つかりません','Keine Gewohnheiten gefunden','습관 없음','Aucune habitude trouvée','未找到习惯','No se encontraron hábitos','Nenhum hábito encontrado','Nessuna abitudine trovata','Geen gewoonten gevonden','لا توجد عادات']);
  String get last8Weeks        => _t(['Last 8 weeks','過去8週間','Letzte 8 Wochen','최근 8주','8 dernières semaines','过去8周','Últimas 8 semanas','Últimas 8 semanas','Ultime 8 settimane','Laatste 8 weken','آخر 8 أسابيع']);
  String get reminder          => _t(['Reminder','リマインダー','Erinnerung','알림','Rappel','提醒','Recordatorio','Lembrete','Promemoria','Herinnering','تذكير']);
  String get everyWeekday      => _t(['Every weekday','毎週平日','Jeden Werktag','매주 평일','Chaque jour ouvrable','每个工作日','Cada día hábil','Todo dia útil','Ogni giorno feriale','Elke werkdag','كل يوم عمل']);
  String get allTimeStats      => _t(['All-time stats','全期間の統計','Gesamtstatistiken','전체 통계','Statistiques totales','全时统计','Estadísticas totales','Estatísticas totais','Statistiche totali','Alle statistieken','الإحصاءات الكلية']);
  String get habitStatistics   => _t(['Habit Statistics','習慣統計','Gewohnheitsstatistiken','습관 통계','Statistiques habitudes','习惯统计','Estadísticas de hábitos','Estatísticas de hábitos','Statistiche abitudini','Gewoonten statistieken','إحصاءات العادات']);
  String get completionRate    => _t(['Completion Rate','完了率','Abschlussrate','완료율','Taux d\'achèvement','完成率','Tasa de finalización','Taxa de conclusão','Tasso di completamento','Voltooiingspercentage','معدل الإنجاز']);
  String get habitCompletion   => _t(['Habit Completion','習慣の完了','Gewohnheitsabschluss','습관 완료','Achèvement des habitudes','习惯完成','Cumplimiento de hábitos','Conclusão de hábitos','Completamento abitudini','Gewoonte voltooiing','إتمام العادات']);
  String get bestDays          => _t(['Best Days','最良の日々','Beste Tage','최고의 날들','Meilleurs jours','最佳日期','Mejores días','Melhores dias','Giorni migliori','Beste dagen','أفضل الأيام']);
  String get archive           => _t(['Archive','アーカイブ','Archivieren','보관','Archiver','归档','Archivar','Arquivar','Archivia','Archiveren','أرشفة']);
  String get snooze            => _t(['Snooze','スヌーズ','Schlummern','다시 알림','Reporter','稍后提醒','Posponer','Adiar','Snooze','Sluimeren','تأجيل']);

  // ── Settings & profile ──────────────────────────────────────────────────────
  String get realTimeSync      => _t(['Real-time sync','リアルタイム同期','Echtzeit-Sync','실시간 동기화','Sync temps réel','实时同步','Sincronización en tiempo real','Sincronização em tempo real','Sync in tempo reale','Realtime sync','مزامنة فورية']);
  String get connectedDevices  => _t(['Connected devices','接続デバイス','Verbundene Geräte','연결된 기기','Appareils connectés','已连接设备','Dispositivos conectados','Dispositivos conectados','Dispositivi connessi','Verbonden apparaten','الأجهزة المتصلة']);
  String get backUpNow         => _t(['Back up now','今すぐバックアップ','Jetzt sichern','지금 백업','Sauvegarder maintenant','立即备份','Respaldar ahora','Fazer backup agora','Esegui backup ora','Nu back-up maken','نسخ احتياطي الآن']);
  String get exportJson        => _t(['Export as JSON','JSONエクスポート','Als JSON exportieren','JSON으로 내보내기','Exporter en JSON','导出为JSON','Exportar como JSON','Exportar como JSON','Esporta come JSON','Exporteren als JSON','تصدير كـJSON']);
  String get studentMode       => _t(['Student Mode','学生モード','Schülermodus','학생 모드','Mode Étudiant','学生模式','Modo Estudiante','Modo Estudante','Modalità Studente','Studentmodus','وضع الطالب']);
  String get onTrack           => _t(['on track','順調','auf Kurs','진행 중','en bonne voie','进展顺利','en camino','no caminho','in pista','op schema','على المسار']);
  String get goPro             => _t(['Go Pro','プロにアップグレード','Pro werden','프로 업그레이드','Passer Pro','升级Pro','Ir a Pro','Ir Pro','Passa a Pro','Ga Pro','الترقية للاحترافي']);

  // ── Notifications, logs, profile actions ────────────────────────────────────
  String get clearAll          => _t(['Clear all','すべてクリア','Alle löschen','모두 지우기','Tout effacer','全部清除','Borrar todo','Limpar tudo','Cancella tutto','Alles wissen','مسح الكل']);
  String get notifications     => _t(['Notifications','通知','Benachrichtigungen','알림','Notifications','通知','Notificaciones','Notificações','Notifiche','Meldingen','الإشعارات']);
  String get allCaughtUp       => _t(['All caught up','すべて確認済み','Alles erledigt','모두 확인됨','Tout vu','全部已读','Todo al día','Tudo em dia','Tutto letto','Alles bijgewerkt','كل شيء محدّث']);
  String get noNewNotifications => _t(['No new notifications','新しい通知なし','Keine neuen Benachrichtigungen','새 알림 없음','Aucune nouvelle notification','没有新通知','Sin nuevas notificaciones','Sem novas notificações','Nessuna nuova notifica','Geen nieuwe meldingen','لا توجد إشعارات جديدة']);
  String get noActivityYet     => _t(['No activity yet','まだ活動なし','Noch keine Aktivität','아직 활동 없음','Aucune activité','暂无活动','Sin actividad aún','Sem atividade ainda','Nessuna attività','Nog geen activiteit','لا نشاط بعد']);
  String get editProfile       => _t(['Edit Profile','プロフィール編集','Profil bearbeiten','프로필 편집','Modifier le profil','编辑个人资料','Editar perfil','Editar perfil','Modifica profilo','Profiel bewerken','تعديل الملف الشخصي']);
  String get signOut           => _t(['Sign out','サインアウト','Abmelden','로그아웃','Se déconnecter','退出登录','Cerrar sesión','Sair','Esci','Uitloggen','تسجيل الخروج']);
  String get noGoalsYet        => _t(['No goals yet. Add one from the Focus tab.','まだ目標がありません。フォーカスタブから追加してください。','Noch keine Ziele. Füge eines im Focus-Tab hinzu.','아직 목표 없음. 포커스 탭에서 추가하세요.','Aucun objectif. Ajoutez-en un dans l\'onglet Focus.','还没有目标。从专注标签页添加一个。','Sin metas aún. Añade una desde la pestaña Focus.','Sem metas ainda. Adicione uma na guia Focus.','Nessun obiettivo ancora. Aggiungine uno dalla scheda Focus.','Nog geen doelen. Voeg er een toe via het Focus-tabblad.','لا توجد أهداف بعد. أضف هدفاً من تبويب Focus.']);
  String get inviteFriends     => _t(['Invite friends','友達を招待','Freunde einladen','친구 초대','Inviter des amis','邀请朋友','Invitar amigos','Convidar amigos','Invita amici','Vrienden uitnodigen','دعوة الأصدقاء']);
  String get freePlan          => _t(['Free plan','無料プラン','Kostenloser Plan','무료 플랜','Plan gratuit','免费计划','Plan gratuito','Plano gratuito','Piano gratuito','Gratis plan','الخطة المجانية']);
  String get brightness        => _t(['Brightness','明るさ','Helligkeit','밝기','Luminosité','亮度','Brillo','Brilho','Luminosità','Helderheid','السطوع']);

  // ── Boards, analytics, widgets, calendar/gmail screens ──────────────────────
  String get board                => _t(['Board','ボード','Board','보드','Tableau','看板','Tablero','Quadro','Bacheca','Bord','لوحة']);
  String get kanbanView           => _t(['Kanban view','カンバンビュー','Kanban-Ansicht','칸반 보기','Vue Kanban','看板视图','Vista Kanban','Visualização Kanban','Vista Kanban','Kanban-weergave','عرض كانبان']);
  String get taskAnalytics        => _t(['Task Analytics','タスク分析','Aufgabenanalyse','작업 분석','Analytique des tâches','任务分析','Análisis de tareas','Análise de tarefas','Analisi attività','Taakanalyse','تحليلات المهام']);
  String get last7Days            => _t(['Last 7 days','過去7日間','Letzte 7 Tage','최근 7일','7 derniers jours','最近7天','Últimos 7 días','Últimos 7 dias','Ultimi 7 giorni','Laatste 7 dagen','آخر 7 أيام']);
  String get unreviewedCaptures   => _t(['Unreviewed captures','未確認のキャプチャ','Nicht überprüfte Erfassungen','미검토 캡처','Captures non examinées','未审核的记录','Capturas sin revisar','Capturas não revisadas','Acquisizioni non revisionate','Niet-beoordeelde vastleggingen','لقطات غير مراجعة']);
  String get sortAll              => _t(['Sort all','すべて並べ替え','Alle sortieren','모두 정렬','Tout trier','全部排序','Ordenar todo','Ordenar tudo','Ordina tutto','Alles sorteren','فرز الكل']);
  String get connectGmailInbox    => _t(['Connect Gmail to see your inbox','Gmailを接続して受信トレイを表示','Gmail verbinden, um Posteingang anzuzeigen','Gmail을 연결하여 받은 편지함 보기','Connecter Gmail pour voir la boîte de réception','连接Gmail查看收件箱','Conectar Gmail para ver tu bandeja de entrada','Conectar Gmail para ver caixa de entrada','Collega Gmail per vedere la posta in arrivo','Gmail verbinden om inbox te zien','ربط Gmail لعرض البريد الوارد']);
  String get widgetPreview        => _t(['Widget Preview','ウィジェットプレビュー','Widget-Vorschau','위젯 미리보기','Aperçu du widget','小组件预览','Vista previa del widget','Visualização do widget','Anteprima widget','Widget-voorvertoning','معاينة الأداة']);
  String get upgrade              => _t(['Upgrade','アップグレード','Upgrade','업그레이드','Améliorer','升级','Mejorar','Atualizar','Aggiorna','Upgraden','ترقية']);
  String get homeWidgetsPro       => _t(['Home screen widgets are Pro','ホーム画面ウィジェットはPro限定','Startbildschirm-Widgets sind Pro','홈 화면 위젯은 Pro 전용','Les widgets d\'écran d\'accueil sont Pro','主屏幕小组件需要Pro版','Los widgets de pantalla de inicio son Pro','Widgets da tela inicial são Pro','I widget della schermata Home sono Pro','Startscherm-widgets zijn Pro','أدوات الشاشة الرئيسية للاشتراك Pro']);
  String get upgradeForWidgets    => _t(['Upgrade to add live widgets to your home screen','ライブウィジェットを追加するにはアップグレード','Upgrade für Live-Widgets auf dem Startbildschirm','홈 화면에 라이브 위젯을 추가하려면 업그레이드','Améliorez pour ajouter des widgets en direct','升级以将实时小组件添加到主屏幕','Mejora para añadir widgets en vivo','Atualize para adicionar widgets ao vivo','Aggiorna per aggiungere widget live alla schermata Home','Upgrade om live widgets toe te voegen','قم بالترقية لإضافة أدوات مباشرة']);
  String get connectGoogleCal     => _t(['Connect Google Calendar','Googleカレンダーを接続','Google Kalender verbinden','Google 캘린더 연결','Connecter Google Agenda','连接Google日历','Conectar Google Calendar','Conectar Google Agenda','Collega Google Calendar','Google Agenda verbinden','ربط تقويم Google']);
  String get neverAutoSendEmails  => _t(['Never auto-send emails','メールの自動送信なし','Nie automatisch senden','이메일 자동 전송 안 함','Ne jamais envoyer automatiquement','永不自动发送邮件','Nunca enviar correos automáticamente','Nunca enviar e-mails automaticamente','Non inviare mai email automaticamente','Nooit automatisch e-mails verzenden','لا ترسل رسائل تلقائياً أبداً']);
  String get alwaysOn             => _t(['Always on','常時オン','Immer ein','항상 켜짐','Toujours activé','始终开启','Siempre activado','Sempre ativado','Sempre attivo','Altijd aan','دائماً مفعّل']);

  bool get isRtl => langIdx == 10;

  // ── TextField hints ──────────────────────────────────────────────────────────
  String get minutesHint      => _t(['Minutes, e.g. 45','分数、例: 45','Minuten, z.B. 45','분, 예: 45','Minutes, ex. 45','分钟，例：45','Minutos, ej. 45','Minutos, ex. 45','Minuti, es. 45','Minuten, bijv. 45','دقائق، مثال: 45']);
  String get addNoteHint      => _t(['Add a note…','メモを追加…','Notiz hinzufügen…','메모 추가…','Ajouter une note…','添加备注…','Agregar una nota…','Adicionar nota…','Aggiungi nota…','Notitie toevoegen…','أضف ملاحظة…']);
  String get addSubtaskHint   => _t(['Add subtask…','サブタスクを追加…','Unteraufgabe hinzufügen…','하위 작업 추가…','Ajouter une sous-tâche…','添加子任务…','Agregar subtarea…','Adicionar subtarefa…','Aggiungi sottoattività…','Subtaak toevoegen…','أضف مهمة فرعية…']);
  String get captureThought   => _t(['Capture a thought…','思いを記録…','Gedanken festhalten…','생각 기록…','Capturer une pensée…','记录想法…','Capturar un pensamiento…','Capturar um pensamento…','Cattura un pensiero…','Gedachte vastleggen…','سجّل فكرة…']);
  String get milestoneTitle   => _t(['Milestone title…','マイルストーンのタイトル…','Meilenstein-Titel…','마일스톤 제목…','Titre du jalon…','里程碑标题…','Título del hito…','Título do marco…','Titolo del traguardo…','Mijlpaaltitel…','عنوان المعلم…']);
  String get brainDumpHint    => _t(['Write everything on your mind — one per line or all together. TaskEra handles the rest.','頭の中のことを書き出して — 1行ずつでも全部まとめても。TaskEraが処理します。','Schreib alles auf — eine pro Zeile oder alles zusammen. TaskEra erledigt den Rest.','마음속 모든 것을 쓰세요 — 한 줄씩 또는 모두 함께. TaskEra이 처리합니다.','Tout écrire — une par ligne ou tout ensemble. TaskEra s\'occupe du reste.','把脑子里所有的事情写下来 — 一行一条或全部一起。TaskEra来处理。','Escribe todo — uno por línea o todo junto. TaskEra se encarga del resto.','Escreva tudo — um por linha ou tudo junto. TaskEra cuida do resto.','Scrivi tutto — uno per riga o tutto insieme. TaskEra pensa al resto.','Schrijf alles op — één per regel of alles samen. TaskEra doet de rest.','اكتب كل ما يدور في ذهنك — سطراً واحداً أو كله معاً. TaskEra يتولى الباقي.']);
  String get startWritingHint => _t(['Start writing… AI will detect tasks, goals & habits','書き始めて… AIがタスク、目標、習慣を検出','Beginne zu schreiben… KI erkennt Aufgaben, Ziele & Gewohnheiten','작성 시작… AI가 작업, 목표 및 습관 감지','Commencez à écrire… L\'IA détectera tâches, objectifs & habitudes','开始写作… AI将检测任务、目标和习惯','Comienza a escribir… La IA detectará tareas, metas y hábitos','Comece a escrever… A IA detectará tarefas, metas e hábitos','Inizia a scrivere… L\'IA rileverà attività, obiettivi e abitudini','Begin met schrijven… AI detecteert taken, doelen & gewoonten','ابدأ الكتابة… سيكتشف الذكاء الاصطناعي المهام والأهداف والعادات']);
  String get listNameHint     => _t(['List name','リスト名','Listenname','목록 이름','Nom de la liste','列表名称','Nombre de la lista','Nome da lista','Nome lista','Lijstnaam','اسم القائمة']);
  String get typeItemOrTap    => _t(['Type item or tap below','アイテムを入力またはタップ','Element tippen oder antippen','항목 입력 또는 탭','Saisir un élément ou appuyer','输入或点击下方','Escribir elemento o tocar','Digitar item ou tocar','Digita o tocca sotto','Item typen of tik hieronder','اكتب عنصراً أو انقر أدناه']);
  String get subtaskTitleHint => _t(['Subtask title','サブタスクのタイトル','Unteraufgabentitel','하위 작업 제목','Titre sous-tâche','子任务标题','Título de subtarea','Título da subtarefa','Titolo sottoattività','Subtaaktitel','عنوان المهمة الفرعية']);
  String get addSubtaskPlus   => _t(['+ Add subtask','+ サブタスク追加','+ Unteraufgabe hinzufügen','+ 하위 작업 추가','+ Ajouter sous-tâche','+ 添加子任务','+ Agregar subtarea','+ Adicionar subtarefa','+ Aggiungi sottoattività','+ Subtaak toevoegen','+ إضافة مهمة فرعية']);

  // ── Remaining screen strings ─────────────────────────────────────────────────
  String get conflicts        => _t(['Conflicts','競合','Konflikte','충돌','Conflits','冲突','Conflictos','Conflitos','Conflitti','Conflicten','التعارضات']);
  String get maybeLater       => _t(['Maybe later','後で','Vielleicht später','나중에','Plus tard','也许以后','Quizás después','Talvez depois','Forse dopo','Misschien later','ربما لاحقاً']);
  String get restorePurchase  => _t(['Restore purchase','購入を復元','Kauf wiederherstellen','구매 복원','Restaurer l\'achat','恢复购买','Restaurar compra','Restaurar compra','Ripristina acquisto','Aankoop herstellen','استعادة الشراء']);
  String get checkingPurchases => _t(['Checking previous purchases…','以前の購入を確認中…','Frühere Käufe werden geprüft…','이전 구매 확인 중…','Vérification des achats précédents…','检查之前的购买…','Verificando compras anteriores…','Verificando compras anteriores…','Verifica acquisti precedenti…','Eerdere aankopen controleren…','جارٍ التحقق من المشتريات السابقة…']);
  String get noLinkedTasksYet  => _t(['No linked tasks yet. Tap to connect tasks to this goal.','まだリンクされたタスクがありません。タップして接続してください。','Noch keine verknüpften Aufgaben. Tippe zum Verbinden.','아직 연결된 작업 없음. 탭하여 연결하세요.','Aucune tâche liée. Appuyez pour connecter.','还没有关联任务。点击进行关联。','Sin tareas vinculadas. Toca para conectar.','Sem tarefas vinculadas. Toque para conectar.','Nessuna attività collegata. Tocca per collegare.','Geen gekoppelde taken. Tik om te koppelen.','لا توجد مهام مرتبطة. انقر للاتصال.']);
  String get noLinkedHabitsYet => _t(['No habits linked yet. Tap to connect habits to this goal.','まだリンクされた習慣がありません。タップして接続してください。','Noch keine verknüpften Gewohnheiten. Tippe zum Verbinden.','아직 연결된 습관 없음. 탭하여 연결하세요.','Aucune habitude liée. Appuyez pour connecter.','还没有关联习惯。点击进行关联。','Sin hábitos vinculados. Toca para conectar.','Sem hábitos vinculados. Toque para conectar.','Nessuna abitudine collegata. Tocca per collegare.','Geen gekoppelde gewoonten. Tik om te koppelen.','لا توجد عادات مرتبطة. انقر للاتصال.']);

  // ── Onboarding, weekly review & goal-form hints ──────────────────────────────
  String get emailHint         => _t(['you@example.com','you@example.com','you@example.com','you@example.com','vous@example.com','you@example.com','tu@ejemplo.com','voce@exemplo.com','tu@esempio.com','u@voorbeeld.com','you@example.com']);
  String get otpHint           => _t(['Enter 6-digit OTP','6桁のOTPを入力','6-stellige OTP eingeben','6자리 OTP 입력','Code OTP à 6 chiffres','输入6位OTP','OTP de 6 dígitos','OTP de 6 dígitos','OTP a 6 cifre','6-cijferige OTP','أدخل رمز OTP المكون من ٦ أرقام']);
  String get yourNameHint      => _t(['Your name','お名前','Ihr Name','이름','Votre nom','您的姓名','Tu nombre','Seu nome','Il tuo nome','Jouw naam','اسمك']);
  String get weeklyWinHint     => _t(['What went really well this week?','今週うまくいったことは？','Was lief diese Woche wirklich gut?','이번 주에 잘 된 것은?','Qu\'est-ce qui s\'est bien passé cette semaine ?','这周哪些事做得很好？','¿Qué salió muy bien esta semana?','O que foi muito bem esta semana?','Cosa è andato davvero bene questa settimana?','Wat ging er echt goed deze week?','ما الذي سار بشكل جيد هذا الأسبوع؟']);
  String get weeklyBlockerHint => _t(['Meetings? Interruptions? Unclear tasks?','会議？中断？不明確なタスク？','Meetings? Unterbrechungen? Unklare Aufgaben?','회의? 방해? 불명확한 작업?','Réunions ? Interruptions ? Tâches floues ?','会议？打扰？任务不清晰？','¿Reuniones? ¿Interrupciones? ¿Tareas poco claras?','Reuniões? Interrupções? Tarefas pouco claras?','Riunioni? Interruzioni? Attività poco chiare?','Vergaderingen? Onderbrekingen? Onduidelijke taken?','اجتماعات؟ مقاطعات؟ مهام غير واضحة؟']);
  String get weeklySuccessHint => _t(['One thing that would make next week a success…','来週を成功させる一つのこと…','Eine Sache für eine erfolgreiche nächste Woche…','다음 주를 성공으로 만들 한 가지…','Une chose pour réussir la semaine prochaine…','让下周成功的一件事…','Una cosa para que la próxima semana sea un éxito…','Uma coisa para a próxima semana ser um sucesso…','Una cosa per far sì che la prossima settimana sia un successo…','Eén ding voor een succesvolle volgende week…','شيء واحد سيجعل الأسبوع القادم ناجحاً…']);
  String get optionalNotesHint => _t(['Optional notes or motivation…','メモや動機（任意）…','Optionale Notizen oder Motivation…','선택적 메모 또는 동기…','Notes optionnelles ou motivation…','可选备注或动力…','Notas opcionales o motivación…','Notas opcionais ou motivação…','Note opzionali o motivazione…','Optionele notities of motivatie…','ملاحظات اختيارية أو دافع…']);
  String get addMilestoneHint  => _t(['Add milestone…','マイルストーンを追加…','Meilenstein hinzufügen…','마일스톤 추가…','Ajouter un jalon…','添加里程碑…','Agregar hito…','Adicionar marco…','Aggiungi traguardo…','Mijlpaal toevoegen…','أضف معلماً…']);
  String get addLinkedTaskHint => _t(['Add a task linked to this goal…','この目標に関連するタスクを追加…','Aufgabe zu diesem Ziel hinzufügen…','이 목표와 연결된 작업 추가…','Ajouter une tâche liée à cet objectif…','添加与此目标关联的任务…','Agregar tarea vinculada a este objetivo…','Adicionar tarefa ligada a esta meta…','Aggiungi attività collegata a questo obiettivo…','Taak toevoegen gekoppeld aan dit doel…','أضف مهمة مرتبطة بهذا الهدف…']);

  // ── Tasks screen ──────────────────────────────────────────────────────────────
  String get doneToday         => _t(['Done today','今日完了','Heute erledigt','오늘 완료','Fait aujourd\'hui','今天完成','Hecho hoy','Feito hoje','Fatto oggi','Vandaag gedaan','تم اليوم']);
  String get doneYesterday     => _t(['Done yesterday','昨日完了','Gestern erledigt','어제 완료','Fait hier','昨天完成','Hecho ayer','Feito ontem','Fatto ieri','Gisteren gedaan','تم أمس']);
  String get listView          => _t(['List','リスト','Liste','목록','Liste','列表','Lista','Lista','Lista','Lijst','قائمة']);
  String get labels            => _t(['Labels','ラベル','Etiketten','레이블','Étiquettes','标签','Etiquetas','Rótulos','Etichette','Labels','تسميات']);
  String get auto              => _t(['Auto','自動','Auto','자동','Auto','自动','Auto','Auto','Auto','Auto','تلقائي']);
  String get checklist         => _t(['Checklist','チェックリスト','Checkliste','체크리스트','Liste de contrôle','清单','Lista de control','Lista de tarefas','Lista di controllo','Checklist','قائمة التحقق']);
  String get timer             => _t(['Timer','タイマー','Timer','타이머','Minuteur','计时器','Temporizador','Temporizador','Timer','Timer','مؤقت']);
  String get history           => _t(['History','履歴','Verlauf','기록','Historique','历史','Historial','Histórico','Cronologia','Geschiedenis','السجل']);
  String get editTask          => _t(['Edit task','タスクを編集','Aufgabe bearbeiten','작업 편집','Modifier la tâche','编辑任务','Editar tarea','Editar tarefa','Modifica attività','Taak bewerken','تعديل المهمة']);
  String get completeTask      => _t(['Complete task','タスクを完了','Aufgabe abschließen','작업 완료','Terminer la tâche','完成任务','Completar tarea','Concluir tarefa','Completa attività','Taak afronden','إكمال المهمة']);
  String get startPomodoro     => _t(['Start Pomodoro','ポモドーロ開始','Pomodoro starten','포모도로 시작','Démarrer Pomodoro','开始番茄钟','Iniciar Pomodoro','Iniciar Pomodoro','Avvia Pomodoro','Pomodoro starten','ابدأ بومودورو']);
  String get deleteTask        => _t(['Delete task','タスクを削除','Aufgabe löschen','작업 삭제','Supprimer la tâche','删除任务','Eliminar tarea','Excluir tarefa','Elimina attività','Taak verwijderen','حذف المهمة']);
  String get restoreTask       => _t(['Restore task','タスクを復元','Aufgabe wiederherstellen','작업 복원','Restaurer la tâche','恢复任务','Restaurar tarea','Restaurar tarefa','Ripristina attività','Taak herstellen','استعادة المهمة']);
  String get deletePermanently => _t(['Delete permanently','完全に削除','Endgültig löschen','영구 삭제','Supprimer définitivement','永久删除','Eliminar permanentemente','Excluir permanentemente','Elimina definitivamente','Definitief verwijderen','حذف نهائياً']);
  String get urgent            => _t(['Urgent','緊急','Dringend','긴급','Urgent','紧急','Urgente','Urgente','Urgente','Urgent','عاجل']);
  String get important         => _t(['Important','重要','Wichtig','중요','Important','重要','Importante','Importante','Importante','Belangrijk','مهم']);
  String get drop              => _t(['Drop','削除','Ignorieren','제거','Ignorer','丢弃','Descartar','Descartar','Scarta','Negeer','تجاهل']);

  // ── Focus screen utility cards ────────────────────────────────────────────────
  String get peakHours         => _t(['Peak Hours','ピーク時間','Spitzenstunden','최고 시간','Heures de pointe','高峰时间','Horas pico','Horas de pico','Ore di punta','Piekuren','ساعات الذروة']);
  String get notEnoughDataYet  => _t(['Not enough data yet','データが不足しています','Noch nicht genug Daten','데이터 부족','Pas assez de données','数据不足','Datos insuficientes','Dados insuficientes','Dati insufficienti','Onvoldoende gegevens','بيانات غير كافية']);
  String get dumpSortLater     => _t(['Dump · sort later','ダンプ · 後で整理','Abladen · später sortieren','덤프 · 나중에 정렬','Vider · trier plus tard','清空 · 稍后整理','Volcar · ordenar luego','Despejar · ordenar depois','Scarica · ordina dopo','Dump · later sorteren','تفريغ · ترتيب لاحقاً']);

  // ── Habits screen ─────────────────────────────────────────────────────────────
  String get thisWeek          => _t(['This week','今週','Diese Woche','이번 주','Cette semaine','本周','Esta semana','Esta semana','Questa settimana','Deze week','هذا الأسبوع']);
  String get skipToday         => _t(['Skip today','今日をスキップ','Heute überspringen','오늘 건너뛰기','Ignorer aujourd\'hui','跳过今天','Saltar hoy','Pular hoje','Salta oggi','Vandaag overslaan','تخطي اليوم']);
  String get reschedule        => _t(['Reschedule','再スケジュール','Neu planen','재일정','Reprogrammer','重新安排','Reprogramar','Reagendar','Riprogramma','Herplannen','إعادة جدولة']);
  String get editHabit         => _t(['Edit habit','習慣を編集','Gewohnheit bearbeiten','습관 편집','Modifier l\'habitude','编辑习惯','Editar hábito','Editar hábito','Modifica abitudine','Gewoonte bewerken','تعديل العادة']);
  String get streakProtect     => _t(['Streak Protect','ストリーク保護','Streak-Schutz','연속 보호','Protection de série','连续保护','Protección de racha','Proteção de sequência','Protezione serie','Reeksbescherming','حماية التتالي']);
  String get streakProtectBody => _t(['Your streak is at risk. Enable Streak Protect to shield your progress on days you can\'t complete your habit.','ストリークが危険！完了できない日に進捗を守るストリーク保護を有効にしてください。','Deine Serie ist in Gefahr! Aktiviere den Streak-Schutz.','연속 기록이 위험해요! 완료 못하는 날에도 연속 기록 보호를 활성화하세요.','Ta série est en danger ! Active la protection de série.','您的连续记录有风险！启用连续保护以保护您的进度。','¡Tu racha está en riesgo! Activa Protección de racha.','Sua sequência está em risco! Ative a Proteção de sequência.','La tua serie è a rischio! Abilita la protezione serie.','Je reeks is in gevaar! Schakel Reeksbescherming in.','سلسلتك في خطر! مكّن حماية التتالي لحفظ تقدمك.']);
  String get enableStreakProtect => _t(['Enable Streak Protect','ストリーク保護を有効にする','Streak-Schutz aktivieren','연속 보호 활성화','Activer la protection de série','启用连续保护','Activar protección de racha','Ativar proteção de sequência','Abilita protezione serie','Reeksbescherming inschakelen','تفعيل حماية التتالي']);
  String get notNow            => _t(['Not now','後で','Nicht jetzt','나중에','Pas maintenant','稍后','Ahora no','Agora não','Non ora','Nu niet','ليس الآن']);
  String get keepGoingLabel    => _t(['Keep going · Enable reminders to protect it','続けて · リマインダーで保護','Weiter so · Erinnerungen aktivieren','계속해요 · 알림으로 보호','Continuez · Activez les rappels','继续 · 启用提醒保护','Continúa · Activa recordatorios','Continue · Ative os lembretes','Continua · Attiva i promemoria','Ga door · Schakel herinneringen in','استمر · فعّل التذكيرات']);
  String get remindLabel       => _t(['Remind','リマインド','Erinnern','알림','Rappeler','提醒','Recordar','Lembrar','Ricorda','Herinneren','تذكير']);
  String get tomorrow          => _t(['Tomorrow','明日','Morgen','내일','Demain','明天','Mañana','Amanhã','Domani','Morgen','غداً']);
  String get nextSession       => _t(['Next session','次のセッション','Nächste Sitzung','다음 세션','Prochaine session','下次会议','Próxima sesión','Próxima sessão','Prossima sessione','Volgende sessie','الجلسة التالية']);
  String get skipDay           => _t(['Skip day','その日スキップ','Tag überspringen','하루 건너뛰기','Passer la journée','跳过这天','Saltar día','Pular dia','Salta giorno','Dag overslaan','تخطي اليوم']);
  String get somethingCameUp   => _t(['Something came up today?','今日何かありましたか？','Heute etwas passiert?','오늘 일이 생겼나요?','Quelque chose s\'est passé aujourd\'hui ?','今天有突发情况？','¿Algo surgió hoy?','Algo surgiu hoje?','Qualcosa è successo oggi?','Iets tussengekomen vandaag?','هل حدث شيء اليوم؟']);
  String get rescheduleHabit => _t(['Reschedule — streaks stay protected','再スケジュール — ストリーク保護','Umplanen — Serien bleiben geschützt','재조정 — 연속 기록 보호','Reprogrammez — série protégée','重新安排 — 连续记录保持保护','Reprograma — rachas protegidas','Reagende — sequências protegidas','Ripianifica — serie protette','Opnieuw plannen — reeksen beschermd','أعد الجدولة — التتاليات محمية']);

  // ── Inbox & notes ─────────────────────────────────────────────────────────────
  String get gmail             => _t(['Gmail','Gmail','Gmail','Gmail','Gmail','Gmail','Gmail','Gmail','Gmail','Gmail','Gmail']);
  String get messages          => _t(['Messages','メッセージ','Nachrichten','메시지','Messages','消息','Mensajes','Mensagens','Messaggi','Berichten','الرسائل']);
  String get aiItems           => _t(['AI items','AIアイテム','KI-Elemente','AI 항목','Éléments IA','AI 项目','Elementos IA','Itens IA','Elementi IA','AI-items','عناصر الذكاء الاصطناعي']);
  String get unread            => _t(['Unread','未読','Ungelesen','미읽음','Non lu','未读','Sin leer','Não lido','Non letto','Ongelezen','غير مقروء']);
  String get added             => _t(['Added','追加済み','Hinzugefügt','추가됨','Ajouté','已添加','Añadido','Adicionado','Aggiunto','Toegevoegd','تمت الإضافة']);
  String get total             => _t(['Total','合計','Gesamt','총계','Total','总计','Total','Total','Totale','Totaal','الإجمالي']);
  String get addedTo           => _t(['Added to','追加先:','Hinzugefügt zu','추가됨:','Ajouté à','已添加到','Añadido a','Adicionado a','Aggiunto a','Toegevoegd aan','تمت الإضافة إلى']);
  String get recentInboxLabel  => _t(['Recent Inbox · last 2 weeks','最近の受信トレイ · 最近2週間','Inbox · letzte 2 Wochen','최근 받은함 · 2주','Boîte récente · 2 dernières semaines','最近收件箱 · 最近2周','Bandeja reciente · últimas 2 semanas','Caixa recente · últimas 2 semanas','Posta recente · ultime 2 settimane','Recente inbox · laatste 2 weken','البريد الأخير · آخر أسبوعين']);
  String get fromYourInbox     => _t(['from your inbox','受信トレイから','aus Ihrem Posteingang','받은함에서','de votre boîte','来自收件箱','de tu bandeja','da sua caixa','dalla tua posta','uit je inbox','من بريدك الوارد']);
  String get inboxEmptyHint    => _t(['New incoming emails will appear here. TaskEra suggests tasks and invites, on your device.','新着メールがここに表示されます。TaskEraが端末上でタスクを提案します。','Neue E-Mails erscheinen hier. TaskEra schlägt Aufgaben auf deinem Gerät vor.','새 이메일이 여기에 표시됩니다. TaskEra이 기기에서 작업을 제안합니다.','Les nouveaux e-mails s\'affichent ici. TaskEra propose des tâches sur votre appareil.','新邮件将显示在这里。TaskEra在您的设备上建议任务。','Los correos nuevos aparecerán aquí. TaskEra sugiere tareas en tu dispositivo.','Novos e-mails aparecerão aqui. TaskEra sugere tarefas no seu dispositivo.','Le nuove email appariranno qui. TaskEra suggerisce attività sul tuo dispositivo.','Nieuwe e-mails verschijnen hier. TaskEra stelt taken voor op je apparaat.','ستظهر الرسائل الجديدة هنا. يقترح TaskEra مهامًا على جهازك.']);
  String get noEmailsLastTwoWeeks => _t(['No emails in the last 2 weeks','最近2週間にメールがありません','Keine E-Mails in den letzten 2 Wochen','최근 2주간 이메일 없음','Pas d\'emails dans les 2 dernières semaines','过去2周没有邮件','Sin emails en las últimas 2 semanas','Sem e-mails nas últimas 2 semanas','Nessuna email nelle ultime 2 settimane','Geen e-mails in de laatste 2 weken','لا رسائل في الأسبوعين الأخيرين']);
  String get connectGmailSeeEmails => _t(['Connect Gmail to see emails','Gmailを接続してメールを見る','Gmail verbinden, um E-Mails zu sehen','Gmail 연결하여 이메일 보기','Connectez Gmail pour voir les emails','连接Gmail查看邮件','Conecta Gmail para ver correos','Conecte o Gmail para ver e-mails','Connetti Gmail per vedere le email','Verbind Gmail om e-mails te zien','اربط Gmail لرؤية الرسائل']);
  String get aiPoweredInboxParsing => _t(['AI-powered inbox parsing','AI搭載の受信解析','KI-gestützte Posteingang-Analyse','AI 기반 받은함 분석','Analyse de boîte de réception par IA','AI驱动的收件箱解析','Análisis de bandeja con IA','Análise de caixa com IA','Analisi posta in arrivo con IA','AI-gestuurde inbox-analyse','تحليل البريد الوارد بالذكاء الاصطناعي']);
  String get connectEmailOrApp => _t(['Connect your email or messaging app','メールまたはメッセージアプリを接続','E-Mail oder Messaging-App verbinden','이메일 또는 메시지 앱 연결','Connectez votre e-mail ou messagerie','连接您的电子邮件或消息应用','Conecta tu email o app de mensajería','Conecte seu e-mail ou app de mensagens','Connetti email o app di messaggistica','Verbind je e-mail of berichtenapp','اربط بريدك الإلكتروني أو تطبيق الرسائل']);
  String get taskeraReadsWithAi   => _t(['TaskEra reads incoming messages on your device','TaskEraが端末上で受信メッセージを解析','TaskEra liest Nachrichten auf deinem Gerät','TaskEra이 기기에서 수신 메시지를 읽음','TaskEra lit les messages entrants sur votre appareil','TaskEra在您的设备上读取传入消息','TaskEra lee mensajes entrantes en tu dispositivo','TaskEra lê mensagens no seu dispositivo','TaskEra legge i messaggi sul tuo dispositivo','TaskEra leest berichten op je apparaat','TaskEra يقرأ الرسائل الواردة على جهازك']);
  String get actionItemsSurfaced => _t(['Action items are surfaced as task suggestions','アクションアイテムがタスク候補として表示','Aufgaben werden als Vorschläge angezeigt','실행 항목이 작업 제안으로 표시됨','Les actions sont suggérées comme tâches','动作项以任务建议形式显示','Los elementos de acción se muestran como tareas','Itens de ação surgem como sugestões','Gli elementi di azione compaiono come suggerimenti','Actiepunten verschijnen als taaksuggesties','تظهر بنود الإجراء كاقتراحات مهام']);
  String get approveOrDismiss  => _t(['Approve or dismiss in the Inbox tab','受信タブで承認または却下','Im Posteingang-Tab genehmigen oder ablehnen','받은함 탭에서 승인 또는 해제','Approuver ou rejeter dans la Boîte de réception','在收件箱标签中批准或关闭','Aprueba o descarta en la pestaña Bandeja','Aprove ou descarte na aba Caixa','Approva o ignora nella scheda Posta','Goedkeuren of verwijderen in inbox-tabblad','وافق أو ارفض في علامة تبويب البريد الوارد']);
  String get pinToTop          => _t(['Pin to top','トップにピン留め','Oben anheften','상단에 고정','Épingler en haut','固定到顶部','Anclar arriba','Fixar no topo','Fissa in alto','Bovenaan vastzetten','تثبيت في الأعلى']);
  String get deleteNote        => _t(['Delete Note','ノートを削除','Notiz löschen','노트 삭제','Supprimer la note','删除笔记','Eliminar nota','Excluir nota','Elimina nota','Notitie verwijderen','حذف الملاحظة']);
  String get emailsScanned     => _t(['Emails scanned','スキャン済みメール','Gescannte E-Mails','스캔된 이메일','Emails analysés','已扫描邮件','Emails escaneados','E-mails escaneados','Email scansionate','Gescande e-mails','رسائل بريد مسحوبة']);
  String get tasksCreated      => _t(['Tasks created','作成されたタスク','Aufgaben erstellt','생성된 작업','Tâches créées','已创建任务','Tareas creadas','Tarefas criadas','Attività create','Gemaakte taken','مهام تم إنشاؤها']);
  String get pendingReview     => _t(['Pending review','レビュー待ち','Ausstehende Überprüfung','검토 대기','En attente de révision','待审核','Revisión pendiente','Revisão pendente','In attesa di revisione','Beoordeling in afwachting','في انتظار المراجعة']);

  // ── Profile screen ────────────────────────────────────────────────────────────
  String get todaysProgress    => _t(['Today\'s progress','今日の進捗','Fortschritt heute','오늘의 진행','Progrès du jour','今日进度','Progreso de hoy','Progresso hoje','Progresso oggi','Voortgang vandaag','تقدم اليوم']);
  String get weeklyReviewLabel => _t(['Weekly review','週次レビュー','Wochenrückblick','주간 리뷰','Bilan hebdomadaire','每周回顾','Revisión semanal','Revisão semanal','Revisione settimanale','Weekelijkse review','المراجعة الأسبوعية']);
  String get startLabel        => _t(['Start ›','開始 ›','Starten ›','시작 ›','Démarrer ›','开始 ›','Iniciar ›','Iniciar ›','Avvia ›','Starten ›','ابدأ ›']);
  String get completedLabel    => _t(['Completed','完了','Erledigt','완료','Terminé','已完成','Completado','Concluído','Completato','Voltooid','مكتمل']);
  String get carriedOver       => _t(['Carried over','持ち越し','Übertragen','이월','Reporté','结转','Aplazado','Transferido','Riportato','Overgedragen','مُرحَّل']);
  String get startWeeklyReview => _t(['Start this week\'s review →','今週のレビューを開始 →','Dieswöchigen Rückblick starten →','이번 주 리뷰 시작 →','Démarrer le bilan de cette semaine →','开始本周回顾 →','Iniciar revisión de esta semana →','Iniciar revisão desta semana →','Avvia revisione di questa settimana →','Start de review van deze week →','ابدأ مراجعة هذا الأسبوع →']);
  String get achievementsLabel => _t(['Achievements','実績','Erfolge','업적','Réalisations','成就','Logros','Conquistas','Risultati','Prestaties','الإنجازات']);
  String get viewAllArrow      => _t(['View all ›','すべて表示 ›','Alle anzeigen ›','모두 보기 ›','Voir tout ›','查看全部 ›','Ver todo ›','Ver tudo ›','Vedi tutto ›','Alles bekijken ›','عرض الكل ›']);
  String get q2RateLabel       => _t(['Q2 rate','Q2 率','Q2-Rate','Q2 비율','Taux Q2','Q2 率','Tasa Q2','Taxa Q2','Tasso Q2','Q2-verhouding','معدل Q2']);
  String get tasksThisWeekLabel => _t(['Tasks · this week','タスク · 今週','Aufgaben · diese Woche','작업 · 이번 주','Tâches · cette semaine','任务 · 本周','Tareas · esta semana','Tarefas · esta semana','Attività · questa settimana','Taken · deze week','مهام · هذا الأسبوع']);
  String get quadrantCompletion => _t(['Quadrant completion','象限完了率','Quadranten-Abschluss','사분면 완료','Complétion quadrants','象限完成率','Compleción cuadrantes','Conclusão quadrantes','Completamento quadranti','Kwadrant-voltooiing','إتمام الأرباع']);
  String get habitsThisWeekLabel => _t(['Habits · this week','習慣 · 今週','Gewohnheiten · diese Woche','습관 · 이번 주','Habitudes · cette semaine','习惯 · 本周','Hábitos · esta semana','Hábitos · esta semana','Abitudini · questa settimana','Gewoonten · deze week','عادات · هذا الأسبوع']);
  String get dStreakSuffix      => _t(['d streak','日連続','T. Serie','일 연속','j série','天连续','días racha','dias streak','g serie','d reeks','يوماً متتالياً']);
  String get noHabitsYet       => _t(['No habits yet.','まだ習慣なし。','Noch keine Gewohnheiten.','아직 습관 없음.','Pas encore d\'habitudes.','还没有习惯。','Sin hábitos todavía.','Sem hábitos ainda.','Nessuna abitudine ancora.','Nog geen gewoonten.','لا عادات بعد.']);
  String get calendarThisWeekLabel => _t(['Calendar · this week','カレンダー · 今週','Kalender · diese Woche','캘린더 · 이번 주','Agenda · cette semaine','日历 · 本周','Calendario · esta semana','Calendário · esta semana','Calendario · questa settimana','Kalender · deze week','التقويم · هذا الأسبوع']);
  String get eventsLabel        => _t(['Events','イベント','Ereignisse','이벤트','Événements','事件','Eventos','Eventos','Eventi','Evenementen','فعاليات']);
  String get deepWorkLabel      => _t(['Deep work','集中作業','Tiefarbeit','깊은 작업','Travail profond','深度工作','Trabajo profundo','Trabalho profundo','Lavoro profondo','Diep werk','عمل عميق']);
  String get aiActionsLabel     => _t(['AI actions','AIアクション','KI-Aktionen','AI 작업','Actions IA','AI 操作','Acciones IA','Ações IA','Azioni IA','AI-acties','إجراءات الذكاء الاصطناعي']);
  String get pinnedLabel        => _t(['Pinned','ピン留め','Angeheftet','고정됨','Épinglé','已固定','Fijado','Fixado','Bloccato','Vastgezet','مثبت']);
  String get taskeraAvgLabel       => _t(['TaskEra avg','TaskEra 平均','TaskEra Ø','TaskEra 평균','Moy. TaskEra','TaskEra 均','Prom. TaskEra','Méd. TaskEra','Med. TaskEra','TaskEra gem.','متوسط TaskEra']);
  String get basedOnLabel       => _t(['Based on','基準:','Basierend auf','기준:','Basé sur','基于','Basado en','Baseado em','Basato su','Gebaseerd op','بناءً على']);
  String get localStorageLabel  => _t(['Local storage','ローカルストレージ','Lokaler Speicher','로컬 저장소','Stockage local','本地存储','Almacenamiento local','Armazenamento local','Archiviazione locale','Lokale opslag','التخزين المحلي']);
  String get memberLabel        => _t(['Member','メンバー','Mitglied','회원','Membre','成员','Miembro','Membro','Membro','Lid','عضو']);
  String get memberSinceLabel   => _t(['Member since','参加:','Mitglied seit','가입:','Membre depuis','成员自','Miembro desde','Membro desde','Membro dal','Lid sinds','عضو منذ']);
  String get monthsAbbr         => _t(['Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec','1月,2月,3月,4月,5月,6月,7月,8月,9月,10月,11月,12月','Jan,Feb,Mär,Apr,Mai,Jun,Jul,Aug,Sep,Okt,Nov,Dez','1월,2월,3월,4월,5월,6월,7월,8월,9월,10월,11월,12월','jan,fév,mar,avr,mai,jun,jul,aoû,sep,oct,nov,déc','1月,2月,3月,4月,5月,6月,7月,8月,9月,10月,11月,12月','ene,feb,mar,abr,may,jun,jul,ago,sep,oct,nov,dic','jan,fev,mar,abr,mai,jun,jul,ago,set,out,nov,dez','gen,feb,mar,apr,mag,giu,lug,ago,set,ott,nov,dic','jan,feb,mrt,apr,mei,jun,jul,aug,sep,okt,nov,dec','يناير,فبراير,مارس,أبريل,مايو,يونيو,يوليو,أغسطس,سبتمبر,أكتوبر,نوفمبر,ديسمبر']);
  String get weekDayAbbrs6      => _t(['M,T,W,T,F,S','月,火,水,木,金,土','Mo,Di,Mi,Do,Fr,Sa','월,화,수,목,금,토','L,M,M,J,V,S','一,二,三,四,五,六','L,M,X,J,V,S','S,T,Q,Q,S,S','L,M,M,G,V,S','M,D,W,D,V,Z','ن,ث,ر,خ,ج,س']);

  // ── Task / habit metadata helpers ────────────────────────────────────────────
  String get someday            => _t(['Someday','いつか','Irgendwann','언젠가','Un jour','某天','Algún día','Algum dia','Un giorno','Ooit','يوماً ما']);
  String get daily              => _t(['Daily','毎日','Täglich','매일','Quotidien','每天','Diario','Diário','Giornaliero','Dagelijks','يومي']);
  String get weeklyRecur        => _t(['Weekly','毎週','Wöchentlich','매주','Hebdomadaire','每周','Semanal','Semanal','Settimanale','Wekelijks','أسبوعي']);

  // ── Calendar / inbox screen helpers ──────────────────────────────────────────
  String get aiThisWeek         => _t(['AI · This week','AI · 今週','KI · Diese Woche','AI · 이번 주','IA · Cette semaine','AI · 本周','IA · Esta semana','IA · Esta semana','IA · Questa settimana','AI · Deze week','الذكاء الاصطناعي · هذا الأسبوع']);
  String get syncSettings       => _t(['Sync settings','同期設定','Synchronisierungseinstellungen','동기화 설정','Paramètres de synchronisation','同步设置','Configuración de sincronización','Configurações de sincronização','Impostazioni di sincronizzazione','Synchronisatie-instellingen','إعدادات المزامنة']);
  String get pendingApproval    => _t(['Pending approval','承認待ち','Ausstehende Genehmigung','승인 대기','Approbation en attente','待审批','Aprobación pendiente','Aprovação pendente','Approvazione in sospeso','Goedkeuring in behandeling','الموافقة معلقة']);
  String get eventsToTaskSugg   => _t(['Events → task suggestions','イベント → タスク提案','Ereignisse → Aufgabenvorschläge','이벤트 → 작업 제안','Événements → suggestions de tâches','事件 → 任务建议','Eventos → sugerencias de tareas','Eventos → sugestões de tarefas','Eventi → suggerimenti attività','Evenementen → taaksuggesties','الأحداث → اقتراحات المهام']);
  String get aiFound            => _t(['AI found','AIが見つけた','KI gefunden','AI 발견','IA trouvé','AI 找到了','IA encontró','IA encontrou','IA ha trovato','AI gevonden','وجد الذكاء الاصطناعي']);
  String get actionableItems    => _t(['actionable items','実行可能アイテム','umsetzbare Elemente','실행 가능한 항목','éléments exploitables','可操作项目','elementos accionables','itens acionáveis','elementi attuabili','uitvoerbare items','عناصر قابلة للتنفيذ']);

  // ── Profile screen — additional stat / badge labels ───────────────────────────
  String get daysLabel         => _t(['days','日','Tage','일','jours','天','días','dias','giorni','dagen','أيام']);
  String get daysAgoLabel      => _t(['days ago','日前','Tage zuvor','일 전','jours','天前','días','dias','giorni fa','dagen geleden','أيام مضت']);
  String get avgLabel          => _t(['avg','平均','Ø','평균','moy.','均','prom.','méd.','med.','gem.','متوسط']);
  String get lastReviewedLabel => _t(['Last reviewed','最終レビュー','Zuletzt geprüft','마지막 검토','Dernière révision','上次检查','Última revisión','Última revisão','Ultima revisione','Laatste revisie','آخر مراجعة']);
  String get badge14DaysStreak => _t(['14 Days\nStreak','14日\n連続','14 Tage\nSerie','14일\n연속','14 Jours\nSérie','14天\n连续','14 Días\nRacha','14 Dias\nSequência','14 Giorni\nSerie','14 Dagen\nReeks','14 يوماً\nمتتالياً']);
  String get badgeQ1Slayer     => _t(['Q1 Slayer\n10 urgent','Q1クリア\n緊急10件','Q1 Bezwinger\n10 dringend','Q1 정복\n긴급 10','Maître Q1\n10 urgents','Q1征服者\n紧急10','Maestro Q1\n10 urgentes','Mestre Q1\n10 urgentes','Maestro Q1\n10 urgenti','Q1 Meester\n10 urgent','فارس Q1\n10 عاجل']);
  String get badgeDeepWork     => _t(['Deep Work\n5h focused','ディープワーク\n5時間集中','Deep Work\n5h fokussiert','깊은 작업\n5h 집중','Travail profond\n5h concentré','深度工作\n5小时专注','Trabajo profundo\n5h enfocado','Trabalho profundo\n5h focado','Lavoro profondo\n5h concentrato','Diep werk\n5u gefocust','عمل عميق\n5 ساعات']);
  String get badgeCentury      => _t(['Century\n100 tasks','百傑\n100タスク','Jahrhundert\n100 Aufgaben','센추리\n100 작업','Centenaire\n100 tâches','百次\n100任务','Centenario\n100 tareas','Centenário\n100 tarefas','Centenario\n100 attività','Eeuw\n100 taken','القرن\n100 مهمة']);
}
