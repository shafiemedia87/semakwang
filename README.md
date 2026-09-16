# Buku Wang — versi Supabase + Vercel

> **Nota:** Projek Supabase untuk app ni **dah siap dicipta** (nama: `buku-wang`,
> region ap-southeast-1) dan skema (`schema.sql`) **dah dijalankan**. URL & anon
> key juga **dah ditampal** dalam `index.html` — jadi Bahagian 1 dan 2 di bawah
> boleh **langkau terus ke Bahagian 3 (Push ke GitHub)**. Bahagian 1–2 disimpan
> di sini sebagai rujukan sekiranya perlu buat projek baru kelak.

Versi ini sama app dengan yang di Claude, tapi storan data dah ditukar
daripada storan dalaman Claude kepada **Supabase** (database + login),
supaya boleh host sendiri di **Vercel** dengan domain sendiri.

Fail dalam folder ini:
- `index.html` — app penuh (satu fail, tiada proses build diperlukan)
- `schema.sql` — skema database untuk Supabase
- `README.md` — panduan ini

---

## 1. Cipta projek Supabase

1. Pergi ke [supabase.com](https://supabase.com) → **New project**.
2. Bila projek siap, pergi ke **SQL Editor** → **New query**.
3. Salin **seluruh kandungan** `schema.sql` → tampal → **Run**.
   Ini akan cipta 2 jadual (`finance_config`, `transactions`), dayakan
   Row Level Security (supaya data setiap pengguna private), dan
   dayakan Realtime sync.
4. Pergi ke **Authentication → Providers**, pastikan **Email** provider
   dihidupkan (biasanya default dah on). Kalau tak nak proses sahkan
   emel (confirmation), pergi ke **Authentication → Settings** dan
   matikan "Confirm email" — senang untuk guna sendiri.
5. Pergi ke **Project Settings → API**. Salin dua nilai ini:
   - **Project URL** (contoh: `https://abcxyz.supabase.co`)
   - **anon public** key (bukan `service_role` — jangan sekali-kali guna
     `service_role` key dalam kod frontend)

## 2. Masukkan kredential ke dalam `index.html`

Buka `index.html`, cari bahagian ini (dekat awal tag `<script>`):

```js
var SUPABASE_URL = 'https://YOUR-PROJECT-REF.supabase.co';
var SUPABASE_ANON_KEY = 'YOUR-ANON-PUBLIC-KEY';
```

Gantikan dengan URL & anon key sebenar dari langkah 1.5 tadi, simpan fail.

## 3. Push ke GitHub

```bash
cd buku-wang-supabase
git init
git add .
git commit -m "Buku Wang - versi Supabase"
git branch -M main
git remote add origin https://github.com/USERNAME/buku-wang.git
git push -u origin main
```

(Cipta repo kosong di GitHub dulu — **New repository** — sebelum
`git push`, dan gantikan `USERNAME/buku-wang` dengan repo sebenar anda.)

## 4. Deploy ke Vercel

1. Pergi ke [vercel.com](https://vercel.com) → **Add New → Project**.
2. Pilih **Import Git Repository** → pilih repo `buku-wang` yang baru
   di-push tadi.
3. Framework Preset: pilih **Other** (ia cuma HTML statik, tiada
   build step diperlukan). Biarkan Build Command & Output Directory
   kosong.
4. Klik **Deploy**. Dalam ~30 saat, Vercel bagi anda URL macam
   `https://buku-wang.vercel.app`.

Setiap kali anda `git push` perubahan baru, Vercel auto re-deploy.

## 5. Guna app

1. Buka URL Vercel anda.
2. Klik **Daftar**, masukkan emel & kata laluan → cipta akaun.
3. Log masuk → mula tambah akaun, komitmen, hutang, simpanan macam
   biasa. Semua disimpan dalam Supabase dan disegerak automatik
   (termasuk antara peranti, sebab Realtime dah dihidupkan).

---

## Nota keselamatan

- `anon` key **selamat** untuk letak dalam kod frontend — akses
  sebenar dikawal oleh **Row Level Security** (RLS) yang dah disetkan
  dalam `schema.sql`: setiap pengguna hanya boleh baca/tulis baris
  data miliknya sendiri (`auth.uid() = user_id`).
- **Jangan sekali-kali** guna `service_role` key dalam `index.html` —
  key itu memintas RLS sepenuhnya dan bagi akses penuh ke semua data.
- Kalau nak tambah pengguna lain (contoh: pasangan), mereka boleh
  daftar akaun sendiri melalui skrin log masuk — data mereka automatik
  berasingan (setiap `user_id` ada baris `finance_config` sendiri).

## Menaik taraf app kemudian

Kalau nanti anda minta Claude tambah ciri baru pada versi asal
(di claude.ai), anda boleh salin bahagian HTML/CSS/JS yang berkaitan
dari situ ke `index.html` ini secara manual — bahagian storan
(Supabase) dalam fail ini berasingan daripada bahagian paparan/UI,
jadi selalunya senang untuk gabungkan semula.
