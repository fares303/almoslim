const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// Function to send notification to a specific topic
async function sendNotificationToTopic(topic, title, body, data = {}) {
  try {
    const message = {
      notification: {
        title,
        body,
      },
      data: {
        ...data,
        timestamp: Date.now().toString(),
      },
      topic,
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          channelId: topic === 'daily_adkar' ? 'adkar_channel' : 
                     topic === 'daily_hadith' ? 'hadith_channel' : 'ayah_channel',
        }
      },
    };

    const response = await admin.messaging().send(message);
    console.log(`Successfully sent message to topic ${topic}:`, response);
    return response;
  } catch (error) {
    console.error(`Error sending message to topic ${topic}:`, error);
    throw error;
  }
}

// Example: Send Adkar notification
async function sendAdkarNotification() {
  const adkarList = [
    {
      title: 'أذكار الصباح',
      body: 'اللهم بك أصبحنا وبك أمسينا وبك نحيا وبك نموت وإليك النشور',
      type: 'morning'
    },
    {
      title: 'أذكار الصباح',
      body: 'أصبحنا على فطرة الإسلام وكلمة الإخلاص، ودين نبينا محمد صلى الله عليه وسلم، وملة أبينا إبراهيم، حنيفا مسلما وما كان من المشركين',
      type: 'morning'
    },
    {
      title: 'أذكار المساء',
      body: 'اللهم بك أمسينا وبك أصبحنا وبك نحيا وبك نموت وإليك المصير',
      type: 'evening'
    },
    {
      title: 'أذكار المساء',
      body: 'أمسينا على فطرة الإسلام وكلمة الإخلاص، ودين نبينا محمد صلى الله عليه وسلم، وملة أبينا إبراهيم، حنيفا مسلما وما كان من المشركين',
      type: 'evening'
    }
  ];

  // Get current hour to determine morning or evening
  const currentHour = new Date().getHours();
  const isMorning = currentHour >= 5 && currentHour < 12;
  
  // Filter adkar by time of day
  const timeOfDay = isMorning ? 'morning' : 'evening';
  const filteredAdkar = adkarList.filter(adkar => adkar.type === timeOfDay);
  
  // Select a random adkar
  const randomAdkar = filteredAdkar[Math.floor(Math.random() * filteredAdkar.length)];
  
  return sendNotificationToTopic(
    'daily_adkar',
    randomAdkar.title,
    randomAdkar.body,
    { type: 'adkar', adkarType: randomAdkar.type }
  );
}

// Example: Send Hadith notification
async function sendHadithNotification() {
  const hadithList = [
    {
      title: 'حديث اليوم',
      body: 'عن أبي هريرة رضي الله عنه قال: قال رسول الله صلى الله عليه وسلم: "من سلك طريقا يلتمس فيه علما سهل الله له به طريقا إلى الجنة"',
      reference: 'رواه مسلم'
    },
    {
      title: 'حديث اليوم',
      body: 'عن أنس بن مالك رضي الله عنه قال: قال رسول الله صلى الله عليه وسلم: "لا يؤمن أحدكم حتى يحب لأخيه ما يحب لنفسه"',
      reference: 'رواه البخاري ومسلم'
    },
    {
      title: 'حديث اليوم',
      body: 'عن أبي هريرة رضي الله عنه قال: قال رسول الله صلى الله عليه وسلم: "المسلم من سلم المسلمون من لسانه ويده، والمهاجر من هجر ما نهى الله عنه"',
      reference: 'رواه البخاري ومسلم'
    }
  ];
  
  // Select a random hadith
  const randomHadith = hadithList[Math.floor(Math.random() * hadithList.length)];
  
  return sendNotificationToTopic(
    'daily_hadith',
    randomHadith.title,
    randomHadith.body,
    { type: 'hadith', reference: randomHadith.reference }
  );
}

// Example: Send Ayah notification
async function sendAyahNotification() {
  const ayahList = [
    {
      title: 'آية اليوم',
      body: 'وَمَا خَلَقْتُ الْجِنَّ وَالْإِنسَ إِلَّا لِيَعْبُدُونِ',
      surah: 'الذاريات',
      ayahNumber: 56
    },
    {
      title: 'آية اليوم',
      body: 'إِنَّمَا الْمُؤْمِنُونَ إِخْوَةٌ فَأَصْلِحُوا بَيْنَ أَخَوَيْكُمْ وَاتَّقُوا اللَّهَ لَعَلَّكُمْ تُرْحَمُونَ',
      surah: 'الحجرات',
      ayahNumber: 10
    },
    {
      title: 'آية اليوم',
      body: 'وَاذْكُر رَّبَّكَ فِي نَفْسِكَ تَضَرُّعًا وَخِيفَةً وَدُونَ الْجَهْرِ مِنَ الْقَوْلِ بِالْغُدُوِّ وَالْآصَالِ وَلَا تَكُن مِّنَ الْغَافِلِينَ',
      surah: 'الأعراف',
      ayahNumber: 205
    }
  ];
  
  // Select a random ayah
  const randomAyah = ayahList[Math.floor(Math.random() * ayahList.length)];
  
  return sendNotificationToTopic(
    'daily_ayah',
    randomAyah.title,
    randomAyah.body,
    { type: 'ayah', surah: randomAyah.surah, ayahNumber: randomAyah.ayahNumber.toString() }
  );
}

// Main function to send all notifications
async function sendAllNotifications() {
  try {
    console.log('Sending Adkar notification...');
    await sendAdkarNotification();
    
    console.log('Sending Hadith notification...');
    await sendHadithNotification();
    
    console.log('Sending Ayah notification...');
    await sendAyahNotification();
    
    console.log('All notifications sent successfully!');
  } catch (error) {
    console.error('Error sending notifications:', error);
  } finally {
    process.exit(0);
  }
}

// Execute the main function
sendAllNotifications();
