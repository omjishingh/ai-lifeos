# E-Sign se Install — Bina Apple ID (Unsigned IPA)

> GitHub Actions **free Mac** par unsigned IPA banata hai.  
> Tum **E-Sign** se apne certificate se sign karke install karoge.  
> **Apple ID / GitHub Secrets ki zaroorat NAHI.**

---

## Step 1 — GitHub par code upload

### PowerShell commands:

```powershell
cd "C:\Users\Acer\Desktop\all folders\SHADULE IPA"

git add .
git commit -m "AI LifeOS unsigned IPA build"
```

### GitHub repo banao (website se):
1. https://github.com/new
2. Name: `ai-lifeos`
3. **Public** repo
4. Create (README mat add karna)

### Push karo:
```powershell
git remote add origin https://github.com/TUMHARA_USERNAME/ai-lifeos.git
git push -u origin main
```

---

## Step 2 — IPA build (automatic)

Push ke baad **khud build shuru** ho jayegi.

Ya manually:
1. GitHub repo → **Actions**
2. **Build Unsigned IPA (E-Sign)** 
3. **Run workflow** → Run

**15–25 minute** wait karo.

---

## Step 3 — IPA download

1. Actions → latest green tick ✅ job
2. Neeche scroll → **Artifacts**
3. **AILifeOS-unsigned-IPA** download karo
4. ZIP kholo → `AILifeOS-unsigned.ipa` milega

---

## Step 4 — E-Sign se iPhone par install

1. `AILifeOS-unsigned.ipa` ko iPhone par bhejo (Telegram, iCloud, USB, etc.)
2. **E-Sign** app kholo
3. IPA file select karo
4. Apna **E-Sign certificate** se sign karo
5. **Install** dabao
6. Settings → VPN & Device Management → Trust (agar puche)

---

## Koi secret nahi chahiye

| Chiz | Zaroorat? |
|------|-----------|
| Apple ID | ❌ Nahi |
| GitHub Secrets | ❌ Nahi |
| Paid Developer | ❌ Nahi |
| Mac | ❌ Nahi |
| E-Sign + Certificate | ✅ Haan (tumhare paas hai) |

---

## Agar build fail ho

1. Actions → failed job → logs dekho
2. **build-log** artifact download karo (agar hai)
3. Error screenshot bhejo — fix kar denge

---

## Quick summary

```
GitHub push → Actions build → Download unsigned IPA → E-Sign install
```

**Apple ID = ZERO. Sirf E-Sign.**
