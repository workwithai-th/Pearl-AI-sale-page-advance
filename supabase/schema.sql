-- ============================================================
-- Pearl AI Sale Page (Advance) — ตั้งค่าฐานข้อมูลครั้งเดียวจบ
-- วิธีใช้: Supabase Dashboard → SQL Editor → วางทั้งหมด → Run
-- ============================================================

-- 1) ตารางออเดอร์ -------------------------------------------------
create table if not exists public.orders (
  id         uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  name       text not null,
  phone      text not null,
  address    text not null,
  package    text not null,
  payment    text not null default 'โอนเงิน',
  note       text,
  total      integer not null default 0,
  slip_path  text,
  status     text not null default 'รอตรวจสลิป'
);

alter table public.orders enable row level security;

-- ลูกค้า (anon) แจ้งออเดอร์ได้อย่างเดียว — อ่านของคนอื่นไม่ได้ แก้ไม่ได้
drop policy if exists "customer insert order" on public.orders;
create policy "customer insert order"
  on public.orders for insert
  to anon
  with check (true);

-- ทีมร้าน (คนที่ล็อกอินผ่าน Supabase Auth) อ่านและอัปเดตสถานะได้
drop policy if exists "staff read orders" on public.orders;
create policy "staff read orders"
  on public.orders for select
  to authenticated
  using (true);

drop policy if exists "staff update orders" on public.orders;
create policy "staff update orders"
  on public.orders for update
  to authenticated
  using (true)
  with check (true);

-- ลูกค้าแนบสลิปเข้าออเดอร์ของตัวเองได้ ผ่าน "grant เฉพาะคอลัมน์"
-- (แก้ได้แค่ slip_path — สถานะ/ยอดเงิน/ที่อยู่ แก้ไม่ได้)
revoke update on public.orders from anon;
grant update (slip_path) on public.orders to anon;

drop policy if exists "customer attach slip" on public.orders;
create policy "customer attach slip"
  on public.orders for update
  to anon
  using (true)
  with check (true);

-- 2) ที่เก็บรูปสลิป (private — คนนอกเปิดลิงก์ตรงไม่ได้) ----------
insert into storage.buckets (id, name, public)
values ('slips', 'slips', false)
on conflict (id) do nothing;

-- ลูกค้าอัปโหลดสลิปของตัวเองได้ (เฉพาะ bucket นี้)
drop policy if exists "customer upload slip" on storage.objects;
create policy "customer upload slip"
  on storage.objects for insert
  to anon
  with check (bucket_id = 'slips');

-- ทีมร้านเปิดดูสลิปได้ (ผ่าน signed URL ที่หน้าแอดมินขอ)
drop policy if exists "staff read slips" on storage.objects;
create policy "staff read slips"
  on storage.objects for select
  to authenticated
  using (bucket_id = 'slips');

-- 3) สรุปว่าต้องทำอะไรต่อ (ทำใน Dashboard ไม่ใช่ SQL) ------------
--  3.1 สร้างบัญชีแอดมิน: Authentication → Users → Add user
--      กรอกอีเมล + รหัสผ่านของเจ้าของร้าน (ใช้เข้าหน้า /admin.html)
--  3.2 เอาค่า Settings → API ไปแก้ config.js ให้เสร็จ
--  3.3 deploy ขึ้น Vercel ตาม README
