import 'package:flutter/material.dart';

import '../app/app_scope.dart';

class S {
  S(this._lang);

  final int _lang;

  static S of(BuildContext context) => S(AppScope.of(context).languageIndex);

  String _t(List<String> v) => v[_lang.clamp(0, v.length - 1)];

  String get appTitle => _t(const [
        'File Share',
        'फ़ाइल शेयर',
        'File Share',
        'File Share',
        'File Share',
        'File Share',
        'File Share',
        'File Share',
        'File Share',
      ]);

  String get selectLanguage => _t(const [
        'Select Language',
        'भाषा चुनें',
        'Pilih Bahasa',
        'Choisir la langue',
        'Sprache wählen',
        'Seleccionar idioma',
        'Selecionar idioma',
        'Seleziona lingua',
        'Выберите язык',
      ]);

  String get done => _t(const [
        'Done',
        'हो गया',
        'Selesai',
        'Terminé',
        'Fertig',
        'Listo',
        'Concluído',
        'Fine',
        'Готово',
      ]);

  String get next => _t(const [
        'Next',
        'आगे',
        'Berikutnya',
        'Suivant',
        'Weiter',
        'Siguiente',
        'Próximo',
        'Avanti',
        'Далее',
      ]);

  String get getStarted => _t(const [
        'Get Started',
        'शुरू करें',
        'Mulai',
        'Commencer',
        'Loslegen',
        'Empezar',
        'Começar',
        'Inizia',
        'Начать',
      ]);

  String get tabSend => _t(const [
        'Send',
        'भेजें',
        'Kirim',
        'Envoyer',
        'Senden',
        'Enviar',
        'Enviar',
        'Invia',
        'Отправить',
      ]);

  String get tabReceive => _t(const [
        'Receive',
        'प्राप्त करें',
        'Terima',
        'Recevoir',
        'Empfangen',
        'Recibir',
        'Receber',
        'Ricevi',
        'Получить',
      ]);

  String get tabSettings => _t(const [
        'Settings',
        'सेटिंग्स',
        'Pengaturan',
        'Réglages',
        'Einstellungen',
        'Ajustes',
        'Ajustes',
        'Impostazioni',
        'Настройки',
      ]);

  String get selectFiles => _t(const [
        'Select Files',
        'फ़ाइलें चुनें',
        'Pilih File',
        'Sélectionner des fichiers',
        'Dateien auswählen',
        'Seleccionar archivos',
        'Selecionar arquivos',
        'Seleziona file',
        'Выбрать файлы',
      ]);

  String get shareFiles => _t(const [
        'Share Files',
        'फ़ाइलें साझा करें',
        'Bagikan File',
        'Partager les fichiers',
        'Dateien teilen',
        'Compartir archivos',
        'Compartilhar arquivos',
        'Condividi file',
        'Поделиться файлами',
      ]);

  String get noFilesSelected => _t(const [
        'No files selected',
        'कोई फ़ाइल नहीं चुनी गई',
        'Tidak ada file dipilih',
        'Aucun fichier sélectionné',
        'Keine Dateien ausgewählt',
        'Ningún archivo seleccionado',
        'Nenhum arquivo selecionado',
        'Nessun file selezionato',
        'Файлы не выбраны',
      ]);

  String get filesSelected => _t(const [
        'files selected',
        'फ़ाइलें चुनी गईं',
        'file dipilih',
        'fichiers sélectionnés',
        'Dateien ausgewählt',
        'archivos seleccionados',
        'arquivos selecionados',
        'file selezionati',
        'файлов выбрано',
      ]);

  String get sendHint => _t(const [
        'On the same Wi‑Fi, scan a receiver QR code to start a secure PIN session, select files, then send directly.',
        'उसी Wi‑Fi पर रिसीवर QR स्कैन करके सुरक्षित PIN सत्र शुरू करें, फ़ाइलें चुनें और सीधे भेजें।',
        'Di Wi‑Fi yang sama, pindai QR penerima untuk sesi PIN aman, pilih file, lalu kirim langsung.',
        'Sur le même Wi‑Fi, scannez le QR pour une session PIN sécurisée, choisissez les fichiers et envoyez.',
        'Im gleichen WLAN QR scannen, PIN-Sitzung starten, Dateien wählen und direkt senden.',
        'En la misma Wi‑Fi, escanea el QR para una sesión PIN segura, elige archivos y envía directo.',
        'Na mesma Wi‑Fi, escaneie o QR para sessão PIN segura, escolha arquivos e envie direto.',
        'Sulla stessa Wi‑Fi, scansiona il QR per sessione PIN sicura, scegli i file e invia.',
        'В той же Wi‑Fi отсканируйте QR для сессии с PIN, выберите файлы и отправьте.',
      ]);

  String get receiveTitle => _t(const [
        'Your Device',
        'आपका डिवाइस',
        'Perangkat Anda',
        'Votre appareil',
        'Ihr Gerät',
        'Tu dispositivo',
        'Seu dispositivo',
        'Il tuo dispositivo',
        'Ваше устройство',
      ]);

  String get receiveHint => _t(const [
        'Start receiving on Wi‑Fi, then show this QR code. Senders scan it to upload files directly to this device.',
        'Wi‑Fi पर रिसीविंग शुरू करें और यह QR दिखाएं। भेजने वाला स्कैन करके फ़ाइलें अपलोड कर सकता है।',
        'Mulai terima di Wi‑Fi, lalu tunjukkan QR ini kepada pengirim.',
        'Démarrez la réception sur le Wi‑Fi et montrez ce QR à l\'expéditeur.',
        'Starten Sie den Empfang im WLAN und zeigen Sie diesen QR-Code.',
        'Inicia la recepción en Wi‑Fi y muestra este código QR.',
        'Inicie o recebimento no Wi‑Fi e mostre este QR.',
        'Avvia la ricezione su Wi‑Fi e mostra questo QR.',
        'Запустите приём по Wi‑Fi и покажите этот QR-код.',
      ]);

  String get scanQr => _t(const [
        'Scan QR Code',
        'QR कोड स्कैन करें',
        'Pindai Kode QR',
        'Scanner le QR',
        'QR-Code scannen',
        'Escanear QR',
        'Escanear QR',
        'Scansiona QR',
        'Сканировать QR',
      ]);

  String get deviceName => _t(const [
        'Device Name',
        'डिवाइस का नाम',
        'Nama Perangkat',
        'Nom de l\'appareil',
        'Gerätename',
        'Nombre del dispositivo',
        'Nome do dispositivo',
        'Nome dispositivo',
        'Имя устройства',
      ]);

  String get save => _t(const [
        'Save',
        'सहेजें',
        'Simpan',
        'Enregistrer',
        'Speichern',
        'Guardar',
        'Salvar',
        'Salva',
        'Сохранить',
      ]);

  String get howToConnect => _t(const [
        'How to Connect',
        'कैसे कनेक्ट करें',
        'Cara Menghubungkan',
        'Comment se connecter',
        'So verbinden Sie',
        'Cómo conectar',
        'Como conectar',
        'Come connettersi',
        'Как подключиться',
      ]);

  String get privacyPolicy => _t(const [
        'Privacy Policy',
        'गोपनीयता नीति',
        'Kebijakan Privasi',
        'Politique de confidentialité',
        'Datenschutz',
        'Política de privacidad',
        'Política de privacidade',
        'Informativa sulla privacy',
        'Политика конфиденциальности',
      ]);

  String get termsOfUse => _t(const [
        'Terms of Use',
        'उपयोग की शर्तें',
        'Syarat Penggunaan',
        'Conditions d\'utilisation',
        'Nutzungsbedingungen',
        'Términos de uso',
        'Termos de uso',
        'Termini di utilizzo',
        'Условия использования',
      ]);

  String get support => _t(const [
        'Support',
        'सहायता',
        'Dukungan',
        'Assistance',
        'Support',
        'Soporte',
        'Suporte',
        'Supporto',
        'Поддержка',
      ]);

  String get version => _t(const [
        'Version',
        'संस्करण',
        'Versi',
        'Version',
        'Version',
        'Versión',
        'Versão',
        'Versione',
        'Версия',
      ]);

  String get language => _t(const [
        'Language',
        'भाषा',
        'Bahasa',
        'Langue',
        'Sprache',
        'Idioma',
        'Idioma',
        'Lingua',
        'Язык',
      ]);

  String get resetOnboarding => _t(const [
        'Show Introduction Again',
        'परिचय फिर दिखाएं',
        'Tampilkan pengenalan lagi',
        'Revoir l\'introduction',
        'Einführung erneut anzeigen',
        'Ver introducción de nuevo',
        'Ver introdução novamente',
        'Mostra di nuovo l\'introduzione',
        'Показать введение снова',
      ]);

  String get cancel => _t(const [
        'Cancel',
        'रद्द करें',
        'Batal',
        'Annuler',
        'Abbrechen',
        'Cancelar',
        'Cancelar',
        'Annulla',
        'Отмена',
      ]);

  String get close => _t(const [
        'Close',
        'बंद करें',
        'Tutup',
        'Fermer',
        'Schließen',
        'Cerrar',
        'Fechar',
        'Chiudi',
        'Закрыть',
      ]);

  String get scannedDevice => _t(const [
        'Device Found',
        'डिवाइस मिला',
        'Perangkat Ditemukan',
        'Appareil trouvé',
        'Gerät gefunden',
        'Dispositivo encontrado',
        'Dispositivo encontrado',
        'Dispositivo trovato',
        'Устройство найдено',
      ]);

  String get receiverNotReady => _t(const [
        'Receiver is not ready. Ask them to tap Start Receiving on the same Wi‑Fi and try again.',
        'रिसीवर तैयार नहीं है। उसी Wi‑Fi पर Start Receiving टैप करने को कहें।',
        'Penerima belum siap. Minta mereka ketuk Mulai Menerima di Wi‑Fi yang sama.',
        'Le récepteur n\'est pas prêt. Demandez-lui de démarrer la réception sur le même Wi‑Fi.',
        'Empfänger nicht bereit. Bitte Empfang im gleichen WLAN starten.',
        'El receptor no está listo. Pide que inicie la recepción en la misma Wi‑Fi.',
        'Receptor não está pronto. Peça para iniciar o recebimento na mesma Wi‑Fi.',
        'Il ricevitore non è pronto. Chiedi di avviare la ricezione sulla stessa Wi‑Fi.',
        'Получатель не готов. Попросите начать приём в той же Wi‑Fi.',
      ]);

  String get invalidQr => _t(const [
        'This QR code is not a valid File Share device code.',
        'यह QR कोड मान्य File Share कोड नहीं है।',
        'Kode QR ini bukan kode File Share yang valid.',
        'Ce QR n\'est pas un code File Share valide.',
        'Dieser QR-Code ist kein gültiger File Share-Code.',
        'Este código QR no es válido para File Share.',
        'Este QR não é um código File Share válido.',
        'Questo QR non è un codice File Share valido.',
        'Этот QR-код недействителен для File Share.',
      ]);

  String get shareSuccess => _t(const [
        'Share sheet opened. You can export the file with another app if you choose.',
        'शेयर शीट खुली। आप चाहें तो किसी अन्य ऐप से निर्यात कर सकते हैं।',
        'Lembar berbagi dibuka. Anda dapat mengekspor dengan app lain jika mau.',
        'Feuille de partage ouverte. Vous pouvez exporter avec une autre app si vous le souhaitez.',
        'Teilen-Dialog geöffnet. Sie können die Datei optional mit einer anderen App exportieren.',
        'Hoja de compartir abierta. Puedes exportar con otra app si lo deseas.',
        'Folha aberta. Você pode exportar com outro app se quiser.',
        'Foglio di condivisione aperto. Puoi esportare con un\'altra app se lo desideri.',
        'Меню «Поделиться» открыто. При желании можно экспортировать через другое приложение.',
      ]);

  String get pickError => _t(const [
        'Could not open the file picker. Please try again.',
        'फ़ाइल पिकर नहीं खुल सका। कृपया पुनः प्रयास करें।',
        'Tidak dapat membuka pemilih file. Coba lagi.',
        'Impossible d\'ouvrir le sélecteur de fichiers.',
        'Dateiauswahl konnte nicht geöffnet werden.',
        'No se pudo abrir el selector de archivos.',
        'Não foi possível abrir o seletor de arquivos.',
        'Impossibile aprire il selettore file.',
        'Не удалось открыть выбор файлов.',
      ]);

  String get onboarding1Title => _t(const [
        'Scan And Connect Device',
        'स्कैन करें और डिवाइस कनेक्ट करें',
        'Pindai dan Hubungkan Perangkat',
        'Scanner et connecter',
        'Gerät scannen und verbinden',
        'Escanear y conectar dispositivo',
        'Escanear e conectar dispositivo',
        'Scansiona e connetti dispositivo',
        'Сканируйте и подключите устройство',
      ]);

  String get onboarding1TitleCompact => _t(const [
        'Scan QR To Connect',
        'QR स्कैन करके कनेक्ट करें',
        'Pindai QR untuk Hubungkan',
        'Scanner le QR pour connecter',
        'QR scannen zum Verbinden',
        'Escanea QR para conectar',
        'Escaneie QR para conectar',
        'Scansiona QR per connettere',
        'Сканируйте QR для подключения',
      ]);

  String get onboarding1Subtitle => _t(const [
        'On the same Wi‑Fi, scan the receiver QR code to start a secure transfer session protected by a PIN.',
        'उसी Wi‑Fi पर रिसीवर QR स्कैन करके PIN से सुरक्षित ट्रांसफ़र सत्र शुरू करें।',
        'Di Wi‑Fi yang sama, pindai QR penerima untuk memulai sesi transfer aman dengan PIN.',
        'Sur le même Wi‑Fi, scannez le QR pour démarrer une session sécurisée avec PIN.',
        'Im gleichen WLAN den Empfänger-QR scannen, um eine PIN-geschützte Sitzung zu starten.',
        'En la misma Wi‑Fi, escanea el QR para iniciar una sesión segura con PIN.',
        'Na mesma Wi‑Fi, escaneie o QR para iniciar sessão segura com PIN.',
        'Sulla stessa Wi‑Fi, scansiona il QR per avviare una sessione sicura con PIN.',
        'В той же Wi‑Fi отсканируйте QR для защищённой сессии с PIN.',
      ]);

  String get onboarding2Title => _t(const [
        'Share With Nearby Devices',
        'पास के डिवाइस के साथ साझा करें',
        'Bagikan ke Perangkat Terdekat',
        'Partager avec des appareils à proximité',
        'Mit Geräten in der Nähe teilen',
        'Compartir con dispositivos cercanos',
        'Compartilhar com dispositivos próximos',
        'Condividi con dispositivi nelle vicinanze',
        'Поделиться с устройствами поблизости',
      ]);

  String get onboarding2TitleCompact => _t(const [
        'Nearby Devices',
        'पास के डिवाइस',
        'Perangkat Terdekat',
        'Appareils proches',
        'Geräte in der Nähe',
        'Dispositivos cercanos',
        'Dispositivos próximos',
        'Dispositivi vicini',
        'Устройства рядом',
      ]);

  String get onboarding2Subtitle => _t(const [
        'Discover receivers on the same Wi‑Fi network, enter a PIN, and transfer files directly with live progress.',
        'उसी Wi‑Fi नेटवर्क पर रिसीवर खोजें, PIN दर्ज करें, और लाइव प्रगति के साथ सीधे फ़ाइलें ट्रांसफ़र करें।',
        'Temukan penerima di jaringan Wi‑Fi yang sama, masukkan PIN, dan transfer file langsung dengan progres langsung.',
        'Découvrez les récepteurs sur le même Wi‑Fi, entrez le PIN et transférez avec suivi en direct.',
        'Empfänger im gleichen WLAN finden, PIN eingeben und Dateien mit Live-Fortschritt übertragen.',
        'Descubre receptores en la misma Wi‑Fi, introduce el PIN y transfiere con progreso en vivo.',
        'Encontre receptores na mesma Wi‑Fi, digite o PIN e transfira com progresso ao vivo.',
        'Trova ricevitori sulla stessa Wi‑Fi, inserisci il PIN e trasferisci con progresso live.',
        'Найдите получателей в той же Wi‑Fi, введите PIN и передавайте файлы с отображением прогресса.',
      ]);

  String get onboarding3Title => _t(const [
        'Share Files With Ease',
        'आसानी से फ़ाइलें साझा करें',
        'Bagikan File dengan Mudah',
        'Partagez vos fichiers facilement',
        'Dateien einfach teilen',
        'Comparte archivos fácilmente',
        'Compartilhe arquivos com facilidade',
        'Condividi file con facilità',
        'Делитесь файлами легко',
      ]);

  String get onboarding3Subtitle => _t(const [
        'Pick your files, connect to a receiver on the same Wi‑Fi, and send with live progress.',
        'अपनी फ़ाइलें चुनें, उसी Wi‑Fi पर रिसीवर से कनेक्ट करें, और लाइव प्रगति के साथ भेजें।',
        'Pilih file, hubungkan ke penerima di Wi‑Fi yang sama, dan kirim dengan progres langsung.',
        'Choisissez vos fichiers, connectez-vous au récepteur sur le même Wi‑Fi et envoyez avec suivi en direct.',
        'Wählen Sie Dateien, verbinden Sie sich im gleichen WLAN und senden Sie mit Live-Fortschritt.',
        'Elige archivos, conéctate al receptor en la misma Wi‑Fi y envía con progreso en vivo.',
        'Escolha arquivos, conecte-se ao receptor na mesma Wi‑Fi e envie com progresso ao vivo.',
        'Scegli i file, connettiti al ricevitore sulla stessa Wi‑Fi e invia con progresso live.',
        'Выберите файлы, подключитесь к получателю в той же Wi‑Fi и отправьте с отображением прогресса.',
      ]);

  String get iosTab => _t(const [
        'iOS',
        'iOS',
        'iOS',
        'iOS',
        'iOS',
        'iOS',
        'iOS',
        'iOS',
        'iOS',
      ]);

  String get androidTab => _t(const [
        'Android',
        'Android',
        'Android',
        'Android',
        'Android',
        'Android',
        'Android',
        'Android',
        'Android',
      ]);

  String get webTab => _t(const [
        'Web Share',
        'वेब शेयर',
        'Web Share',
        'Partage Web',
        'Web-Share',
        'Compartir Web',
        'Compartilhar Web',
        'Condivisione Web',
        'Веб-отправка',
      ]);

  String get step1Ios => _t(const [
        'On the receiving iPhone or iPad, open Receive and tap Start Receiving on the same Wi‑Fi.',
        'रिसीविंग iPhone या iPad पर Receive खोलें और Start Receiving टैप करें।',
        'Di iPhone atau iPad penerima, buka Terima dan ketuk Mulai Menerima.',
        'Sur l\'iPhone ou iPad destinataire, ouvrez Recevoir et démarrez la réception.',
        'Auf dem empfangenden iPhone oder iPad Empfang starten.',
        'En el iPhone o iPad receptor, abre Recibir e inicia la recepción.',
        'No iPhone ou iPad receptor, abra Receber e inicie o recebimento.',
        'Su iPhone o iPad ricevente, apri Ricevi e avvia la ricezione.',
        'На принимающем iPhone или iPad откройте «Получить» и начните приём.',
      ]);

  String get step2Ios => _t(const [
        'On the sending device, scan the QR code, enter the PIN if requested, select files, then tap Send Directly.',
        'भेजने वाले डिवाइस पर QR स्कैन करें, PIN दर्ज करें, फ़ाइलें चुनें और Send Directly टैप करें।',
        'Di perangkat pengirim, pindai QR, masukkan PIN jika diminta, pilih file, lalu ketuk Kirim Langsung.',
        'Sur l\'appareil expéditeur, scannez le QR, entrez le PIN si demandé, choisissez les fichiers et envoyez.',
        'Scannen Sie den QR, geben Sie ggf. die PIN ein, wählen Sie Dateien und senden Sie direkt.',
        'En el dispositivo emisor, escanea el QR, introduce el PIN si se pide, elige archivos y envía.',
        'No dispositivo remetente, escaneie o QR, digite o PIN se solicitado, escolha arquivos e envie.',
        'Sul dispositivo mittente, scansiona il QR, inserisci il PIN se richiesto e invia.',
        'На отправляющем устройстве отсканируйте QR, введите PIN при запросе и отправьте файлы.',
      ]);

  String get step3Ios => _t(const [
        'Received files appear on the receiver. You can share or delete them from the list.',
        'प्राप्त फ़ाइलें रिसीवर पर दिखेंगी। आप उन्हें साझा या हटा सकते हैं।',
        'File diterima muncul di penerima dan dapat dibagikan atau dihapus.',
        'Les fichiers reçus apparaissent sur le destinataire.',
        'Empfangene Dateien erscheinen in der Liste.',
        'Los archivos recibidos aparecen en el receptor.',
        'Os arquivos recebidos aparecem na lista.',
        'I file ricevuti compaiono nell\'elenco.',
        'Полученные файлы появятся в списке на приёмнике.',
      ]);

  String get step1Android => _t(const [
        'On the receiving Android device, open Receive and tap Start Receiving on the same Wi‑Fi.',
        'रिसीविंग Android पर Receive खोलें और उसी Wi‑Fi पर Start Receiving टैप करें।',
        'Di Android penerima, buka Terima dan ketuk Mulai Menerima di Wi‑Fi yang sama.',
        'Sur l\'Android destinataire, ouvrez Recevoir et démarrez la réception sur le même Wi‑Fi.',
        'Auf dem empfangenden Android Gerät Empfang auf dem gleichen WLAN starten.',
        'En el Android receptor, abre Recibir e inicia la recepción en la misma Wi‑Fi.',
        'No Android receptor, abra Receber e inicie o recebimento na mesma Wi‑Fi.',
        'Su Android ricevente, apri Ricevi e avvia la ricezione sulla stessa Wi‑Fi.',
        'На принимающем Android откройте «Получить» и начните приём в той же Wi‑Fi.',
      ]);

  String get step1Web => _t(const [
        'On a phone or computer browser, open the URL from the receiver QR code, enter the PIN, and upload files to the same Wi‑Fi session.',
        'फ़ोन या कंप्यूटर ब्राउज़र में रिसीवर QR का URL खोलें, PIN दर्ज करें और उसी Wi‑Fi सत्र में फ़ाइलें अपलोड करें।',
        'Di browser ponsel/komputer, buka URL dari QR penerima, masukkan PIN, lalu unggah file ke sesi Wi‑Fi yang sama.',
        'Dans un navigateur, ouvrez l\'URL du QR du récepteur, entrez le PIN et envoyez les fichiers sur le même Wi‑Fi.',
        'Im Browser die URL aus dem Empfänger-QR öffnen, PIN eingeben und Dateien im gleichen WLAN hochladen.',
        'En un navegador, abre la URL del QR del receptor, introduce el PIN y sube archivos en la misma Wi‑Fi.',
        'No navegador, abra a URL do QR do receptor, digite o PIN e envie arquivos na mesma Wi‑Fi.',
        'Nel browser, apri l\'URL del QR del ricevitore, inserisci il PIN e carica i file sulla stessa Wi‑Fi.',
        'В браузере откройте URL из QR получателя, введите PIN и загрузите файлы в той же Wi‑Fi сессии.',
      ]);

  String get startReceiving => _t(const [
        'Start Receiving',
        'रिसीविंग शुरू करें',
        'Mulai Menerima',
        'Commencer à recevoir',
        'Empfang starten',
        'Empezar a recibir',
        'Iniciar recebimento',
        'Inizia a ricevere',
        'Начать приём',
      ]);

  String get stopReceiving => _t(const [
        'Stop Receiving',
        'रिसीविंग बंद करें',
        'Berhenti Menerima',
        'Arrêter la réception',
        'Empfang stoppen',
        'Dejar de recibir',
        'Parar recebimento',
        'Ferma ricezione',
        'Остановить приём',
      ]);

  String get waitingForFiles => _t(const [
        'Waiting for files… Screen stays awake while receiving on the same Wi‑Fi.',
        'फ़ाइलों की प्रतीक्षा… रिसीविंग के दौरान स्क्रीन सक्रिय रहेगी।',
        'Menunggu file… Layar tetap aktif saat menerima.',
        'En attente… L\'écran reste actif pendant la réception.',
        'Warte auf Dateien… Bildschirm bleibt beim Empfang aktiv.',
        'Esperando archivos… La pantalla permanece activa.',
        'Aguardando arquivos… A tela permanece ativa.',
        'In attesa… Lo schermo resta attivo.',
        'Ожидание файлов… Экран не гаснет во время приёма.',
      ]);

  String get sendDirectly => _t(const [
        'Send Directly',
        'सीधे भेजें',
        'Kirim Langsung',
        'Envoyer directement',
        'Direkt senden',
        'Enviar directamente',
        'Enviar diretamente',
        'Invia direttamente',
        'Отправить напрямую',
      ]);

  String get sendViaOtherApps => _t(const [
        'Other Apps',
        'अन्य ऐप',
        'App Lain',
        'Autres apps',
        'Andere Apps',
        'Otras apps',
        'Outros apps',
        'Altre app',
        'Другие приложения',
      ]);

  String get scanToConnect => _t(const [
        'Scan Receiver QR',
        'रिसीवर QR स्कैन करें',
        'Pindai QR Penerima',
        'Scanner le QR',
        'Empfänger-QR scannen',
        'Escanear QR receptor',
        'Escanear QR do receptor',
        'Scansiona QR destinatario',
        'Сканировать QR',
      ]);

  String get connectedTo => _t(const [
        'Connected to',
        'कनेक्टेड',
        'Terhubung ke',
        'Connecté à',
        'Verbunden mit',
        'Conectado a',
        'Conectado a',
        'Connesso a',
        'Подключено к',
      ]);

  String get nearbyReceivers => _t(const [
        'Nearby Receivers',
        'पास के रिसीवर',
        'Penerima Terdekat',
        'Récepteurs à proximité',
        'Empfänger in der Nähe',
        'Receptores cercanos',
        'Receptores próximos',
        'Ricevitori vicini',
        'Устройства рядом',
      ]);

  String get nearbyReceiversHint => _t(const [
        'Devices on the same Wi‑Fi or nearby over Bluetooth. Tap one and enter its PIN.',
        'उसी Wi‑Fi या Bluetooth पर पास के डिवाइस। टैप करें और PIN दर्ज करें।',
        'Perangkat di Wi‑Fi yang sama atau terdekat via Bluetooth. Ketuk lalu masukkan PIN.',
        'Appareils sur le même Wi‑Fi ou à proximité via Bluetooth. Touchez puis entrez le PIN.',
        'Geräte im gleichen WLAN oder in der Nähe per Bluetooth. Tippen und PIN eingeben.',
        'Dispositivos en la misma Wi‑Fi o cercanos por Bluetooth. Toca e introduce el PIN.',
        'Dispositivos na mesma Wi‑Fi ou próximos por Bluetooth. Toque e digite o PIN.',
        'Dispositivi sulla stessa Wi‑Fi o vicini via Bluetooth. Tocca e inserisci il PIN.',
        'Устройства в той же Wi‑Fi или рядом по Bluetooth. Нажмите и введите PIN.',
      ]);

  String get offlineReceiving => _t(const [
        'Offline mode — nearby Apple devices can connect',
        'ऑफ़लाइन मोड — पास के Apple डिवाइस कनेक्ट कर सकते हैं',
        'Mode offline — perangkat Apple terdekat dapat terhubung',
        'Mode hors ligne — les appareils Apple à proximité peuvent se connecter',
        'Offline-Modus — Apple-Geräte in der Nähe können verbinden',
        'Modo sin conexión — dispositivos Apple cercanos pueden conectarse',
        'Modo offline — dispositivos Apple próximos podem conectar',
        'Modalità offline — i dispositivi Apple vicini possono connettersi',
        'Офлайн-режим — устройства Apple рядом могут подключиться',
      ]);

  String get offlinePeer => _t(const [
        'Offline (Bluetooth)',
        'ऑफ़लाइन (Bluetooth)',
        'Offline (Bluetooth)',
        'Hors ligne (Bluetooth)',
        'Offline (Bluetooth)',
        'Sin conexión (Bluetooth)',
        'Offline (Bluetooth)',
        'Offline (Bluetooth)',
        'Офлайн (Bluetooth)',
      ]);

  String get noNearbyReceivers => _t(const [
        'No receivers found yet. Make sure receiving is started on the other device.',
        'अभी कोई रिसीवर नहीं मिला। दूसरे डिवाइस पर रिसीविंग शुरू करें।',
        'Belum ada penerima. Pastikan penerimaan sudah dimulai di perangkat lain.',
        'Aucun récepteur trouvé. Démarrez la réception sur l\'autre appareil.',
        'Keine Empfänger gefunden. Starten Sie den Empfang auf dem anderen Gerät.',
        'No se encontraron receptores. Inicia la recepción en el otro dispositivo.',
        'Nenhum receptor encontrado. Inicie o recebimento no outro dispositivo.',
        'Nessun ricevitore trovato. Avvia la ricezione sull\'altro dispositivo.',
        'Получатели не найдены. Запустите приём на другом устройстве.',
      ]);

  String get enterPinTitle => _t(const [
        'Enter PIN',
        'PIN दर्ज करें',
        'Masukkan PIN',
        'Entrer le PIN',
        'PIN eingeben',
        'Introducir PIN',
        'Digite o PIN',
        'Inserisci PIN',
        'Введите PIN',
      ]);

  String enterPinBody(String deviceName) => _t(const [
        'Enter the 4-digit PIN shown on %s.',
        '%s पर दिखाया गया 4-अंकीय PIN दर्ज करें।',
        'Masukkan PIN 4 digit yang ditampilkan di %s.',
        'Entrez le PIN à 4 chiffres affiché sur %s.',
        'Geben Sie die 4-stellige PIN ein, die auf %s angezeigt wird.',
        'Introduce el PIN de 4 dígitos mostrado en %s.',
        'Digite o PIN de 4 dígitos exibido em %s.',
        'Inserisci il PIN a 4 cifre mostrato su %s.',
        'Введите 4-значный PIN, показанный на %s.',
      ]).replaceFirst('%s', deviceName);

  String get enterPinHint => _t(const [
        '1234',
        '1234',
        '1234',
        '1234',
        '1234',
        '1234',
        '1234',
        '1234',
        '1234',
      ]);

  String get connect => _t(const [
        'Connect',
        'कनेक्ट करें',
        'Hubungkan',
        'Connecter',
        'Verbinden',
        'Conectar',
        'Conectar',
        'Connetti',
        'Подключить',
      ]);

  String get disconnect => _t(const [
        'Disconnect',
        'डिस्कनेक्ट',
        'Putuskan',
        'Déconnecter',
        'Trennen',
        'Desconectar',
        'Desconectar',
        'Disconnetti',
        'Отключить',
      ]);

  String get receivedFiles => _t(const [
        'Received Files',
        'प्राप्त फ़ाइलें',
        'File Diterima',
        'Fichiers reçus',
        'Empfangene Dateien',
        'Archivos recibidos',
        'Arquivos recebidos',
        'File ricevuti',
        'Полученные файлы',
      ]);

  String get noReceivedFiles => _t(const [
        'No files received yet',
        'अभी कोई फ़ाइल नहीं मिली',
        'Belum ada file diterima',
        'Aucun fichier reçu',
        'Noch keine Dateien empfangen',
        'Aún no hay archivos',
        'Nenhum arquivo recebido',
        'Nessun file ricevuto',
        'Файлы ещё не получены',
      ]);

  String get uploadComplete => _t(const [
        'Files sent successfully',
        'फ़ाइलें सफलतापूर्वक भेजी गईं',
        'File berhasil dikirim',
        'Fichiers envoyés',
        'Dateien gesendet',
        'Archivos enviados',
        'Arquivos enviados',
        'File inviati',
        'Файлы отправлены',
      ]);

  String get uploadFailed => _t(const [
        'Upload failed',
        'अपलोड विफल',
        'Upload gagal',
        'Échec de l\'envoi',
        'Upload fehlgeschlagen',
        'Error al enviar',
        'Falha no envio',
        'Invio non riuscito',
        'Ошибка отправки',
      ]);

  String get retryUpload => _t(const [
        'Retry',
        'पुनः प्रयास करें',
        'Coba lagi',
        'Réessayer',
        'Erneut versuchen',
        'Reintentar',
        'Tentar novamente',
        'Riprova',
        'Повторить',
      ]);

  String get retryUploadHint => _t(const [
        'Upload stopped at %s. %d file(s) remaining.',
        'अपलोड %s पर रुका। %d फ़ाइल(ें) बाकी।',
        'Upload berhenti di %s. %d file tersisa.',
        'Envoi arrêté à %s. %d fichier(s) restant(s).',
        'Upload bei %s gestoppt. %d Datei(en) übrig.',
        'Envío detenido en %s. %d archivo(s) pendiente(s).',
        'Envio parou em %s. %d arquivo(s) restante(s).',
        'Invio interrotto su %s. %d file rimanenti.',
        'Отправка остановлена на %s. Осталось файлов: %d.',
      ]);

  String get dismiss => _t(const [
        'Dismiss',
        'खारिज करें',
        'Tutup',
        'Ignorer',
        'Schließen',
        'Descartar',
        'Dispensar',
        'Chiudi',
        'Закрыть',
      ]);

  String get deleteFile => _t(const [
        'Delete',
        'हटाएं',
        'Hapus',
        'Supprimer',
        'Löschen',
        'Eliminar',
        'Excluir',
        'Elimina',
        'Удалить',
      ]);

  String get shareReceived => _t(const [
        'Share',
        'साझा करें',
        'Bagikan',
        'Partager',
        'Teilen',
        'Compartir',
        'Compartilhar',
        'Condividi',
        'Поделиться',
      ]);

  String get sessionPin => _t(const [
        'Session PIN',
        'सेशन PIN',
        'PIN Sesi',
        'PIN de session',
        'Sitzungs-PIN',
        'PIN de sesión',
        'PIN da sessão',
        'PIN sessione',
        'PIN сессии',
      ]);

  String get sessionPinHint => _t(const [
        'Share this PIN with the sender if they use a browser.',
        'ब्राउज़र से भेजने पर यह PIN साझा करें।',
        'Bagikan PIN ini jika pengirim memakai browser.',
        'Partagez ce PIN si l\'expéditeur utilise un navigateur.',
        'Teilen Sie diese PIN bei Browser-Uploads.',
        'Comparte este PIN si envían desde un navegador.',
        'Compartilhe este PIN para envio pelo navegador.',
        'Condividi il PIN per invii dal browser.',
        'Сообщите PIN при отправке через браузер.',
      ]);

  String get saveToFiles => _t(const [
        'Save to Files',
        'Files में सहेजें',
        'Simpan ke Files',
        'Enregistrer dans Fichiers',
        'In Dateien speichern',
        'Guardar en Archivos',
        'Salvar em Arquivos',
        'Salva in File',
        'Сохранить в Файлы',
      ]);

  String get savedToFiles => _t(const [
        'Saved to Files',
        'Files में सहेजा गया',
        'Disimpan ke Files',
        'Enregistré dans Fichiers',
        'In Dateien gespeichert',
        'Guardado en Archivos',
        'Salvo em Arquivos',
        'Salvato in File',
        'Сохранено в Файлы',
      ]);

  String get saveToFilesFailed => _t(const [
        'Could not save to Files',
        'Files में सहेजना विफल',
        'Gagal menyimpan ke Files',
        'Échec de l\'enregistrement',
        'Speichern fehlgeschlagen',
        'No se pudo guardar',
        'Falha ao salvar',
        'Salvataggio non riuscito',
        'Не удалось сохранить',
      ]);

  String get cancelUpload => _t(const [
        'Cancel',
        'रद्द करें',
        'Batal',
        'Annuler',
        'Abbrechen',
        'Cancelar',
        'Cancelar',
        'Annulla',
        'Отмена',
      ]);

  String get uploadCancelled => _t(const [
        'Upload cancelled',
        'अपलोड रद्द किया गया',
        'Upload dibatalkan',
        'Envoi annulé',
        'Upload abgebrochen',
        'Envío cancelado',
        'Envio cancelado',
        'Invio annullato',
        'Отправка отменена',
      ]);
}
