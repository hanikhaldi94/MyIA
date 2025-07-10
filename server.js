app.use(cors());
const express = require("express");
const askGemini = require("./puppeteer-gemini");
const app = express();
const port = process.env.PORT || 3000; // ✅ ضروري لـ Render

const bodyParser = require("body-parser");
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(express.static("public"));

const queue = [];
let processing = false;

async function processQueue() {
  if (processing || queue.length === 0) return;

  processing = true;
  const { question, res } = queue.shift();

  console.log("✅ سؤال جديد:", question);

  try {
    const answer = await askGemini(question);
    res.json({ answer });
  } catch (err) {
    console.error("❌ خطأ أثناء سؤال Gemini:", err);
    res.json({ answer: "❌ فشل في المعالجة." });
  }

  processing = false;
  processQueue(); // معالجة السؤال التالي
}

app.post("/ask", (req, res) => {
  const question = req.body.question;
  if (!question) {
    return res.json({ answer: "❌ لا يوجد سؤال." });
  }

  queue.push({ question, res });
  processQueue(); // بدء المعالجة إذا لم تكن تعمل
});

app.listen(port, () => {
  console.log(`✅ السيرفر يعمل على: http://localhost:${port}`);
});
