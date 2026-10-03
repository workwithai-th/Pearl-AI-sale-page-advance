/* ตั้งค่าระบบหน้าขาย (Supabase) — แก้แค่ไฟล์นี้ไฟล์เดียว
   ค่าทั้งสองหาได้จาก: Supabase Dashboard → เลือกโปรเจกต์ → Settings → API
   - Project URL  → SUPABASE_URL
   - anon public key → SUPABASE_ANON_KEY
   (anon key ออกแบบให้ฝั่งเว็บได้ — ความปลอดภัยคุมด้วย RLS ใน supabase/schema.sql)
*/
window.SALEPAGE_CONFIG = {
  SUPABASE_URL: "https://YOUR-PROJECT.supabase.co",
  SUPABASE_ANON_KEY: "YOUR-ANON-KEY-ที่นี่",
};
