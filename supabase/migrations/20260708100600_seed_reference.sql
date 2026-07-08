-- AriyaPlanner — reference data seed (P4). PRODUCTION content: program templates,
-- price bands, advisory tips, idea assets, aso-ebi palettes. Demo events live in
-- supabase/seed.sql (dev only).
--
-- Idempotent: templates/price_bands use their natural unique keys; tips, idea
-- assets and palettes use fixed UUIDs — all with ON CONFLICT DO NOTHING, so this
-- file is safe to re-run.
--
-- IMPORTANT (skills/cultural-programs): every non-office template ships
-- is_live = false with reviewed_by empty — DRAFT ceremony structure pending
-- cultural-consultant review. RLS hides non-live templates from users, so nothing
-- unreviewed can reach a family. The Office Celebration template is culture-neutral
-- with no ritual content and ships live.

-- ── program_templates (13) ────────────────────────────────────────────────────
insert into program_templates (event_type, culture, religion, name, version, is_live, reviewed_by, blocks) values

('wedding', 'yoruba', 'traditional', 'Yoruba Traditional Engagement', 1, false, null, $j$[
  {"order":1,"title":"Arrival and seating of families","description":"Guests and both families are seated; the alaga set the tone.","duration_min":30,"default_time_hint":"late morning","roles":["alaga_ijoko","alaga_iduro"],"vendor_categories":["decor","catering","canopy_rentals"],"optional":false,"notes":"Confirm arrangements with family elders — customs vary by family and town."},
  {"order":2,"title":"Introduction and welcome","description":"The alaga iduro (groom's side) greets and engages the bride's family.","duration_min":20,"default_time_hint":null,"roles":["alaga_iduro","mc"],"vendor_categories":[],"optional":false,"notes":null},
  {"order":3,"title":"Proposal letter read and answered","description":"The groom's family letter is presented and the bride's family responds.","duration_min":15,"default_time_hint":null,"roles":["alaga_ijoko"],"vendor_categories":[],"optional":false,"notes":null},
  {"order":4,"title":"Prostration (idobale) of the groom","description":"The groom and his friends greet the bride's family.","duration_min":20,"default_time_hint":null,"roles":["alaga_iduro"],"vendor_categories":[],"optional":true,"notes":"Confirm custom with elders."},
  {"order":5,"title":"Presentation and acceptance of engagement gifts","description":"The eru iyawo is presented and received.","duration_min":30,"default_time_hint":null,"roles":["alaga_ijoko","alaga_iduro"],"vendor_categories":[],"optional":false,"notes":null},
  {"order":6,"title":"Bride's entrance and parental blessing","description":"The bride is welcomed and blessed by parents and elders.","duration_min":20,"default_time_hint":null,"roles":["mc"],"vendor_categories":[],"optional":false,"notes":null},
  {"order":7,"title":"Prayers, cake and refreshments","description":"Closing prayers, cutting of cake and refreshments.","duration_min":45,"default_time_hint":null,"roles":["mc"],"vendor_categories":["catering","cake","dj"],"optional":false,"notes":null}
]$j$::jsonb),

('wedding', 'igbo', 'traditional', 'Igbo Traditional Wedding (Igba Nkwu)', 1, false, null, $j$[
  {"order":1,"title":"Arrival and kola nut presentation","description":"Guests are received; kola nut is presented and broken by elders.","duration_min":20,"default_time_hint":"late morning","roles":["elder","mc"],"vendor_categories":["decor","catering"],"optional":false,"notes":"Confirm sequence with the umunna and family elders."},
  {"order":2,"title":"Introductions and intention","description":"The groom's family states its intention to the bride's kindred.","duration_min":20,"default_time_hint":null,"roles":["mc","elder"],"vendor_categories":[],"optional":false,"notes":null},
  {"order":3,"title":"List and bride-price settlement","description":"The families settle the list with the umunna in private.","duration_min":30,"default_time_hint":null,"roles":["elder"],"vendor_categories":[],"optional":false,"notes":"Handled discreetly by elders; details vary by town."},
  {"order":4,"title":"Igba nkwu — the wine carrying","description":"The bride seeks the groom in the crowd and offers him palm wine.","duration_min":30,"default_time_hint":null,"roles":["mc"],"vendor_categories":[],"optional":false,"notes":null},
  {"order":5,"title":"Blessing of the couple","description":"The bride's father and elders bless the couple.","duration_min":20,"default_time_hint":null,"roles":["elder"],"vendor_categories":[],"optional":false,"notes":null},
  {"order":6,"title":"Feasting and celebration","description":"Feasting, dancing and presentation of gifts.","duration_min":90,"default_time_hint":null,"roles":["mc"],"vendor_categories":["catering","dj","live_band"],"optional":false,"notes":null}
]$j$::jsonb),

('wedding', 'hausa', 'muslim', 'Hausa Wedding (Fatiha)', 1, false, null, $j$[
  {"order":1,"title":"Fatiha (marriage contract)","description":"The nikkah/Fatiha is conducted by the imam, often at the mosque.","duration_min":30,"default_time_hint":"morning","roles":["imam","elder"],"vendor_categories":[],"optional":false,"notes":"Led by the imam; confirm arrangements with the family."},
  {"order":2,"title":"Sadaki (dowry) confirmation","description":"The agreed sadaki is confirmed.","duration_min":15,"default_time_hint":null,"roles":["imam","elder"],"vendor_categories":[],"optional":false,"notes":null},
  {"order":3,"title":"Kayan zance and gifts","description":"Gifts are presented to the bride.","duration_min":30,"default_time_hint":null,"roles":[],"vendor_categories":[],"optional":true,"notes":null},
  {"order":4,"title":"Walima (reception feast)","description":"The reception feast for family and guests.","duration_min":90,"default_time_hint":null,"roles":["mc"],"vendor_categories":["catering","decor","dj"],"optional":false,"notes":null},
  {"order":5,"title":"Prayers and blessings","description":"Closing prayers led by the imam.","duration_min":15,"default_time_hint":null,"roles":["imam"],"vendor_categories":[],"optional":false,"notes":null}
]$j$::jsonb),

('wedding', 'neutral', 'christian', 'White Wedding and Reception', 1, false, null, $j$[
  {"order":1,"title":"Guest seating and prelude","description":"Ushers seat guests; music sets the mood.","duration_min":30,"default_time_hint":"late morning","roles":["ushers"],"vendor_categories":["decor","photography"],"optional":false,"notes":null},
  {"order":2,"title":"Processional and entrance of the bride","description":"The bridal party and bride process in.","duration_min":30,"default_time_hint":null,"roles":["mc"],"vendor_categories":["photography","videography"],"optional":false,"notes":null},
  {"order":3,"title":"Church service","description":"Hymns, sermon, exchange of vows and rings.","duration_min":60,"default_time_hint":null,"roles":["officiant"],"vendor_categories":[],"optional":false,"notes":null},
  {"order":4,"title":"Signing of the register and recessional","description":"The register is signed; the couple recesses.","duration_min":15,"default_time_hint":null,"roles":["officiant"],"vendor_categories":[],"optional":false,"notes":null},
  {"order":5,"title":"Photographs","description":"Family and couple photographs.","duration_min":30,"default_time_hint":null,"roles":[],"vendor_categories":["photography","videography"],"optional":false,"notes":null},
  {"order":6,"title":"Reception","description":"Entrance, toasts, first dance, cutting of the cake and dinner.","duration_min":120,"default_time_hint":"afternoon","roles":["mc"],"vendor_categories":["catering","cake","dj","live_band","decor"],"optional":false,"notes":"Pairs with a traditional ceremony where both are held."}
]$j$::jsonb),

('wedding', 'neutral', 'neutral', 'Culture-Neutral Wedding (Fallback)', 1, false, null, $j$[
  {"order":1,"title":"Arrival and welcome","description":"Guests are welcomed and seated.","duration_min":20,"default_time_hint":"late morning","roles":["mc","ushers"],"vendor_categories":["decor","catering"],"optional":false,"notes":"A neutral structure — adapt to the family's own tradition; confirm with elders."},
  {"order":2,"title":"Opening and prayers","description":"Opening remarks and prayers.","duration_min":15,"default_time_hint":null,"roles":["mc"],"vendor_categories":[],"optional":false,"notes":null},
  {"order":3,"title":"Main ceremony and vows","description":"The core ceremony and exchange of vows.","duration_min":60,"default_time_hint":null,"roles":["officiant","mc"],"vendor_categories":[],"optional":false,"notes":"Adapt to the family's tradition."},
  {"order":4,"title":"Blessings and introductions","description":"Blessings and introduction of families.","duration_min":20,"default_time_hint":null,"roles":["mc","elder"],"vendor_categories":[],"optional":false,"notes":null},
  {"order":5,"title":"Reception and feasting","description":"Feasting, cake and dancing.","duration_min":90,"default_time_hint":null,"roles":["mc"],"vendor_categories":["catering","cake","dj"],"optional":false,"notes":null}
]$j$::jsonb),

('burial', 'neutral', 'christian', 'Christian Burial', 1, false, null, $j$[
  {"order":1,"title":"Wake-keep / night of tributes","description":"An evening gathering of tributes and songs.","duration_min":90,"default_time_hint":"evening before","roles":["mc"],"vendor_categories":["canopy_rentals","catering","program_printing"],"optional":true,"notes":"Confirm arrangements with the family."},
  {"order":2,"title":"Service of songs","description":"A service of songs in memory of the departed.","duration_min":60,"default_time_hint":null,"roles":["officiant"],"vendor_categories":["program_printing"],"optional":true,"notes":null},
  {"order":3,"title":"Funeral service","description":"The funeral service at the church.","duration_min":90,"default_time_hint":"morning","roles":["officiant","pallbearers"],"vendor_categories":["program_printing"],"optional":false,"notes":null},
  {"order":4,"title":"Committal / interment","description":"The committal and interment at the graveside.","duration_min":45,"default_time_hint":null,"roles":["officiant","pallbearers"],"vendor_categories":["hearse_transport"],"optional":false,"notes":null},
  {"order":5,"title":"Reception of guests","description":"Guests are received and refreshments served.","duration_min":90,"default_time_hint":"afternoon","roles":["mc"],"vendor_categories":["catering","canopy_rentals"],"optional":false,"notes":null},
  {"order":6,"title":"Traditional rites (where applicable)","description":"Igbo ikwa ozu and related observances where the family keeps them.","duration_min":null,"default_time_hint":null,"roles":["elder"],"vendor_categories":[],"optional":true,"notes":"Flagged optional — include only if the family observes them; confirm with elders."}
]$j$::jsonb),

('burial', 'neutral', 'muslim', 'Muslim Janazah', 1, false, null, $j$[
  {"order":1,"title":"Ghusl and shrouding (kafan)","description":"Washing and shrouding of the deceased.","duration_min":null,"default_time_hint":"as soon as possible","roles":["family","imam"],"vendor_categories":[],"optional":false,"notes":"Islamic burial is prompt — usually within 24 hours."},
  {"order":2,"title":"Janazah prayer","description":"Salat al-Janazah led by the imam.","duration_min":20,"default_time_hint":null,"roles":["imam"],"vendor_categories":[],"optional":false,"notes":null},
  {"order":3,"title":"Burial / interment","description":"Interment at the cemetery.","duration_min":30,"default_time_hint":null,"roles":["imam"],"vendor_categories":["hearse_transport"],"optional":false,"notes":null},
  {"order":4,"title":"Condolence gathering","description":"Family receives condolences over the following days.","duration_min":60,"default_time_hint":null,"roles":[],"vendor_categories":["catering"],"optional":true,"notes":null}
]$j$::jsonb),

('naming', 'yoruba', 'traditional', 'Yoruba Naming Ceremony', 1, false, null, $j$[
  {"order":1,"title":"Officiant arrangement","description":"Arrange the officiant (pastor, imam or family elder) to lead the ceremony.","duration_min":null,"default_time_hint":null,"roles":["officiant"],"vendor_categories":[],"optional":false,"notes":"Procurement task — confirm availability at least two days ahead."},
  {"order":2,"title":"Gathering of family and guests","description":"Family and guests gather, usually on the 7th or 8th day.","duration_min":20,"default_time_hint":"morning","roles":["mc"],"vendor_categories":["decor","catering"],"optional":false,"notes":null},
  {"order":3,"title":"Symbolic items presentation and tasting","description":"The symbolic items are presented, tasted and prayed over.","duration_min":30,"default_time_hint":null,"roles":["elder","officiant"],"vendor_categories":[],"optional":false,"notes":"Procure ahead: honey (sweetness), kola nut (longevity), bitter kola (long life), alligator pepper (fruitfulness), salt (wisdom and flavour), sugar or sugar-cane (a sweet life), water (purity), palm oil (ease), dried fish (leadership). Confirm the list with family elders."},
  {"order":4,"title":"Naming","description":"The child's names are announced by parents and elders.","duration_min":20,"default_time_hint":null,"roles":["elder","officiant"],"vendor_categories":[],"optional":false,"notes":null},
  {"order":5,"title":"Prayers and blessings","description":"Prayers and blessings over the child and family.","duration_min":15,"default_time_hint":null,"roles":["officiant"],"vendor_categories":[],"optional":false,"notes":null},
  {"order":6,"title":"Refreshments","description":"Refreshments for family and guests.","duration_min":45,"default_time_hint":null,"roles":["mc"],"vendor_categories":["catering","small_chops"],"optional":false,"notes":null}
]$j$::jsonb),

('naming', 'neutral', 'christian', 'Christian Naming / Dedication', 1, false, null, $j$[
  {"order":1,"title":"Officiant arrangement","description":"Arrange the pastor to lead the dedication.","duration_min":null,"default_time_hint":null,"roles":["officiant"],"vendor_categories":[],"optional":false,"notes":"Procurement task — confirm availability ahead of the day."},
  {"order":2,"title":"Gathering and welcome","description":"Family and guests gather and are welcomed.","duration_min":20,"default_time_hint":"morning","roles":["mc"],"vendor_categories":["decor","catering"],"optional":false,"notes":null},
  {"order":3,"title":"Dedication and naming prayer","description":"The child is presented and dedicated in prayer.","duration_min":30,"default_time_hint":null,"roles":["officiant"],"vendor_categories":[],"optional":false,"notes":null},
  {"order":4,"title":"Announcement of names","description":"The parents announce the child's names.","duration_min":15,"default_time_hint":null,"roles":["mc"],"vendor_categories":[],"optional":false,"notes":null},
  {"order":5,"title":"Refreshments","description":"Refreshments for family and guests.","duration_min":45,"default_time_hint":null,"roles":["mc"],"vendor_categories":["catering","small_chops"],"optional":false,"notes":null}
]$j$::jsonb),

('naming', 'neutral', 'muslim', 'Muslim Naming (Aqiqah, 7th day)', 1, false, null, $j$[
  {"order":1,"title":"Aqiqah ram procurement","description":"Arrange and slaughter the aqiqah ram per custom.","duration_min":null,"default_time_hint":null,"roles":["family"],"vendor_categories":[],"optional":false,"notes":"TIME-CRITICAL procurement — arrange the ram 1–2 days ahead (custom is two for a boy, one for a girl; confirm with the imam/family)."},
  {"order":2,"title":"Officiant arrangement","description":"Arrange the imam to lead the ceremony.","duration_min":null,"default_time_hint":null,"roles":["officiant","imam"],"vendor_categories":[],"optional":false,"notes":"Procurement task — confirm availability ahead."},
  {"order":3,"title":"Shaving of hair and naming","description":"The baby's hair is shaved and the name given, usually on the 7th day.","duration_min":30,"default_time_hint":"morning","roles":["imam","elder"],"vendor_categories":[],"optional":false,"notes":null},
  {"order":4,"title":"Prayers (dua) and announcement of name","description":"Prayers and announcement of the child's name.","duration_min":20,"default_time_hint":null,"roles":["imam"],"vendor_categories":[],"optional":false,"notes":null},
  {"order":5,"title":"Distribution of meat and refreshments","description":"The aqiqah meat is shared and refreshments served.","duration_min":60,"default_time_hint":null,"roles":["mc"],"vendor_categories":["catering"],"optional":false,"notes":null}
]$j$::jsonb),

('birthday', 'neutral', 'neutral', 'Milestone Birthday (40th / 50th / 70th)', 1, false, null, $j$[
  {"order":1,"title":"Arrival and cocktails","description":"Guests arrive and are received.","duration_min":30,"default_time_hint":"evening","roles":["ushers","mc"],"vendor_categories":["decor","small_chops"],"optional":false,"notes":null},
  {"order":2,"title":"Welcome and opening","description":"The MC opens the celebration.","duration_min":15,"default_time_hint":null,"roles":["mc"],"vendor_categories":[],"optional":false,"notes":null},
  {"order":3,"title":"Tributes","description":"Family and friends share tributes.","duration_min":30,"default_time_hint":null,"roles":["mc"],"vendor_categories":["videography"],"optional":true,"notes":null},
  {"order":4,"title":"Dinner","description":"Dinner is served.","duration_min":60,"default_time_hint":null,"roles":[],"vendor_categories":["catering"],"optional":false,"notes":null},
  {"order":5,"title":"Cake cutting and toast","description":"Cutting of the cake and a toast.","duration_min":20,"default_time_hint":null,"roles":["mc"],"vendor_categories":["cake"],"optional":false,"notes":null},
  {"order":6,"title":"Music and dancing","description":"Music and dancing to close.","duration_min":90,"default_time_hint":null,"roles":["mc"],"vendor_categories":["dj","live_band"],"optional":false,"notes":null}
]$j$::jsonb),

('birthday', 'neutral', 'neutral', 'Standard Celebration', 1, false, null, $j$[
  {"order":1,"title":"Arrival and welcome","description":"Guests arrive and are welcomed.","duration_min":20,"default_time_hint":null,"roles":["mc","ushers"],"vendor_categories":["decor"],"optional":false,"notes":null},
  {"order":2,"title":"Opening and prayers","description":"Opening remarks and prayers.","duration_min":10,"default_time_hint":null,"roles":["mc"],"vendor_categories":[],"optional":false,"notes":null},
  {"order":3,"title":"Meal and refreshments","description":"Food and refreshments are served.","duration_min":60,"default_time_hint":null,"roles":[],"vendor_categories":["catering","small_chops"],"optional":false,"notes":null},
  {"order":4,"title":"Cake cutting","description":"Cutting of the cake.","duration_min":15,"default_time_hint":null,"roles":["mc"],"vendor_categories":["cake"],"optional":false,"notes":null},
  {"order":5,"title":"Music and dancing","description":"Music and dancing.","duration_min":90,"default_time_hint":null,"roles":[],"vendor_categories":["dj"],"optional":false,"notes":null}
]$j$::jsonb),

('office', 'neutral', 'neutral', 'Office Celebration', 1, true, 'n/a — culture-neutral, no ritual content', $j$[
  {"order":1,"title":"Arrival and registration","description":"Colleagues arrive and sign in.","duration_min":30,"default_time_hint":null,"roles":["logistics_lead"],"vendor_categories":["venue"],"optional":false,"notes":null},
  {"order":2,"title":"Welcome address","description":"A welcome from the host or lead.","duration_min":15,"default_time_hint":null,"roles":["mc"],"vendor_categories":[],"optional":false,"notes":null},
  {"order":3,"title":"Programme / recognition","description":"Awards, recognition or the main programme.","duration_min":45,"default_time_hint":null,"roles":["mc"],"vendor_categories":["av"],"optional":true,"notes":null},
  {"order":4,"title":"Refreshments and networking","description":"Food, drinks and networking.","duration_min":60,"default_time_hint":null,"roles":["logistics_lead"],"vendor_categories":["catering","decor"],"optional":false,"notes":null},
  {"order":5,"title":"Closing remarks","description":"Closing remarks and thanks.","duration_min":10,"default_time_hint":null,"roles":["mc"],"vendor_categories":[],"optional":false,"notes":null}
]$j$::jsonb)

on conflict (event_type, culture, religion, name, version) do nothing;

-- ── price_bands (Lagos, 2026 seed research; kobo) ─────────────────────────────
insert into price_bands (category, city, tier, low_kobo, high_kobo, unit) values
  ('decor','lagos','manage',15000000,30000000,'flat'),
  ('decor','lagos','standard',30000000,150000000,'flat'),
  ('decor','lagos','premium',200000000,500000000,'flat'),
  ('catering_per_head','lagos','manage',350000,600000,'per_head'),
  ('catering_per_head','lagos','standard',600000,1000000,'per_head'),
  ('catering_per_head','lagos','premium',1000000,2000000,'per_head'),
  ('dj','lagos','manage',8000000,15000000,'flat'),
  ('dj','lagos','standard',15000000,50000000,'flat'),
  ('dj','lagos','premium',50000000,120000000,'flat'),
  ('mc','lagos','manage',5000000,10000000,'flat'),
  ('mc','lagos','standard',10000000,35000000,'flat'),
  ('mc','lagos','premium',35000000,80000000,'flat'),
  ('alaga','lagos','manage',5000000,10000000,'flat'),
  ('alaga','lagos','standard',10000000,20000000,'flat'),
  ('alaga','lagos','premium',20000000,40000000,'flat'),
  ('photography','lagos','manage',10000000,20000000,'flat'),
  ('photography','lagos','standard',20000000,60000000,'flat'),
  ('photography','lagos','premium',60000000,150000000,'flat'),
  ('videography','lagos','manage',12000000,25000000,'flat'),
  ('videography','lagos','standard',25000000,70000000,'flat'),
  ('videography','lagos','premium',70000000,180000000,'flat'),
  ('venue','lagos','manage',20000000,50000000,'flat'),
  ('venue','lagos','standard',50000000,200000000,'flat'),
  ('venue','lagos','premium',200000000,800000000,'flat'),
  ('small_chops','lagos','manage',150000,300000,'per_head'),
  ('small_chops','lagos','standard',300000,500000,'per_head'),
  ('small_chops','lagos','premium',500000,1000000,'per_head'),
  ('cake','lagos','manage',4000000,10000000,'flat'),
  ('cake','lagos','standard',10000000,35000000,'flat'),
  ('cake','lagos','premium',35000000,100000000,'flat'),
  ('souvenirs','lagos','manage',150000,400000,'per_unit'),
  ('souvenirs','lagos','standard',400000,1000000,'per_unit'),
  ('souvenirs','lagos','premium',1000000,3000000,'per_unit'),
  ('aso_ebi_unit','lagos','manage',1500000,3000000,'per_unit'),
  ('aso_ebi_unit','lagos','standard',3000000,6000000,'per_unit'),
  ('aso_ebi_unit','lagos','premium',6000000,15000000,'per_unit'),
  ('ushers','lagos','manage',3000000,6000000,'flat'),
  ('ushers','lagos','standard',6000000,12000000,'flat'),
  ('ushers','lagos','premium',12000000,25000000,'flat'),
  ('security','lagos','manage',5000000,10000000,'flat'),
  ('security','lagos','standard',10000000,25000000,'flat'),
  ('security','lagos','premium',25000000,60000000,'flat'),
  ('canopy_rentals','lagos','manage',8000000,20000000,'flat'),
  ('canopy_rentals','lagos','standard',20000000,50000000,'flat'),
  ('canopy_rentals','lagos','premium',50000000,120000000,'flat'),
  ('funeral_home','lagos','manage',15000000,40000000,'flat'),
  ('funeral_home','lagos','standard',40000000,100000000,'flat'),
  ('funeral_home','lagos','premium',100000000,300000000,'flat'),
  ('casket','lagos','manage',15000000,40000000,'flat'),
  ('casket','lagos','standard',40000000,120000000,'flat'),
  ('casket','lagos','premium',120000000,500000000,'flat'),
  ('hearse_transport','lagos','manage',6000000,15000000,'flat'),
  ('hearse_transport','lagos','standard',15000000,35000000,'flat'),
  ('hearse_transport','lagos','premium',35000000,80000000,'flat'),
  ('program_printing','lagos','manage',30000,80000,'per_unit'),
  ('program_printing','lagos','standard',80000,200000,'per_unit'),
  ('program_printing','lagos','premium',200000,500000,'per_unit'),
  ('live_band','lagos','manage',25000000,50000000,'flat'),
  ('live_band','lagos','standard',50000000,150000000,'flat'),
  ('live_band','lagos','premium',150000000,400000000,'flat')
on conflict (category, city, tier, version) do nothing;

-- Abuja = Lagos +10% (placeholder until Abuja research lands; skills/price-bands).
insert into price_bands (category, city, tier, low_kobo, high_kobo, unit, source, effective_from, version)
select category, 'abuja', tier,
       round(low_kobo * 1.1)::bigint, round(high_kobo * 1.1)::bigint,
       unit, source, effective_from, version
from price_bands where city = 'lagos'
on conflict (category, city, tier, version) do nothing;

-- ── tips library v1 (PRD F1c) ─────────────────────────────────────────────────
insert into tips (id, event_type, workstream_slug, runway_stage, guest_band, body_celebration, body_memorial) values
  ('f0000000-0000-0000-0000-000000000001','wedding','catering','comfortable',null,'Lock your caterer 8–10 weeks out and pay a deposit — it secures the date and hedges against price rises closer to the day.',null),
  ('f0000000-0000-0000-0000-000000000002','wedding','decor','tight',null,'With under two weeks, choose a decorator who can work from ready stock rather than a bespoke build — ask what they can deliver from inventory.',null),
  ('f0000000-0000-0000-0000-000000000003','wedding','finance','comfortable','600_plus','For a large guest list, agree catering on a firm per-head rate and set a final headcount deadline to avoid last-minute cost spikes.',null),
  ('f0000000-0000-0000-0000-000000000004','wedding','vendors','comfortable',null,'Compare at least three quotes for each major vendor — a fair price is a range, not a single number.',null),
  ('f0000000-0000-0000-0000-000000000005','burial','catering','sprint',null,'Confirm expected numbers for the reception early so the caterer can plan calmly.','With days to the service, confirm expected numbers for the reception early so the caterer can plan calmly.'),
  ('f0000000-0000-0000-0000-000000000006','burial','logistics','sprint',null,'Appoint one person to receive guests and run the programme.','Appoint one family member to receive guests and coordinate the programme, so the immediate family can be present to grieve.'),
  ('f0000000-0000-0000-0000-000000000007','burial','finance','tight',null,'Track support by family branch and keep amounts private to the family lead.','Track support by family branch and keep amounts private to the family lead.'),
  ('f0000000-0000-0000-0000-000000000008','burial','vendors','sprint',null,'Ask each vendor for their earliest realistic delivery, not their ideal.','Ask each vendor for their earliest realistic delivery, not their ideal — a short runway rewards honesty.'),
  ('f0000000-0000-0000-0000-000000000009','naming','catering','sprint','under_100','Naming ceremonies are usually intimate — cater for close family with a small margin; small chops travel well.',null),
  ('f0000000-0000-0000-0000-00000000000a','naming','logistics','sprint',null,'Confirm the officiant (pastor, imam or elder) at least two days ahead — availability is the usual bottleneck.',null),
  ('f0000000-0000-0000-0000-00000000000b','birthday','decor','comfortable',null,'Book decor 4–6 weeks out and share your colour palette early so it threads through the cake, stage and aso-ebi.',null),
  ('f0000000-0000-0000-0000-00000000000c','birthday','catering','tight','100_300','At short notice for a mid-size crowd, a buffet with two proteins keeps service moving and costs predictable.',null),
  ('f0000000-0000-0000-0000-00000000000d','office','logistics','comfortable',null,'Send calendar holds and a simple RSVP early — an accurate headcount is the biggest lever on an office-event budget.',null),
  ('f0000000-0000-0000-0000-00000000000e','office','catering','tight',null,'For a short-runway office celebration, finger foods and a drinks station beat a plated meal and are easier to staff.',null)
on conflict (id) do nothing;

-- ── idea_assets v1 (placeholder owned/licensed references, PRD F1c) ────────────
insert into idea_assets (id, category, title, storage_path, license_source, license_note) values
  ('f1000000-0000-0000-0000-000000000001','decor','Emerald & gold arch','idea-assets/decor/arch-emerald-gold.jpg','owned','Placeholder — replace with owned photography pre-launch.'),
  ('f1000000-0000-0000-0000-000000000002','decor','Draped entrance','idea-assets/decor/entrance-drape.jpg','owned','Placeholder — replace pre-launch.'),
  ('f1000000-0000-0000-0000-000000000003','aso_ebi','Coral & cream lace','idea-assets/aso-ebi/coral-cream.jpg','licensed','Placeholder — confirm licence before launch.'),
  ('f1000000-0000-0000-0000-000000000004','cake','Three-tier classic','idea-assets/cake/three-tier.jpg','owned','Placeholder — replace pre-launch.'),
  ('f1000000-0000-0000-0000-000000000005','stage','Milestone birthday stage','idea-assets/stage/milestone-backdrop.jpg','owned','Placeholder — replace pre-launch.'),
  ('f1000000-0000-0000-0000-000000000006','table','Table setting, warm neutrals','idea-assets/table/warm-neutrals.jpg','owned','Placeholder — replace pre-launch.'),
  ('f1000000-0000-0000-0000-000000000007','souvenirs','Curated souvenir set','idea-assets/souvenirs/curated-set.jpg','owned','Placeholder — replace pre-launch.'),
  ('f1000000-0000-0000-0000-000000000008','memorial','Dignified memorial setting','idea-assets/memorial/sage-setting.jpg','owned','Placeholder — replace pre-launch; memorial register.')
on conflict (id) do nothing;

-- ── aso-ebi palettes (deterministic colour-chip cards, PRD F1c) ───────────────
insert into aso_ebi_palettes (id, name, hexes, description, register, position) values
  ('f2000000-0000-0000-0000-000000000001','Emerald & Gold','{"#0B6B3A","#C9A227","#FBF7F0"}','Rich and celebratory; the house default.','celebration',1),
  ('f2000000-0000-0000-0000-000000000002','Coral & Cream','{"#E8735A","#F6E7D8"}','Warm and modern.','celebration',2),
  ('f2000000-0000-0000-0000-000000000003','Royal Blue & Silver','{"#1E3A8A","#C0C5CE","#FFFFFF"}','Formal and striking.','celebration',3),
  ('f2000000-0000-0000-0000-000000000004','Burgundy & Blush','{"#7B1E3B","#E8C7C8"}','Elegant, softly contrasting.','celebration',4),
  ('f2000000-0000-0000-0000-000000000005','Deep Purple & Gold','{"#4C1D6B","#C9A227"}','Regal and bold.','celebration',5),
  ('f2000000-0000-0000-0000-000000000006','Ivory & Champagne','{"#F7F1E1","#E4CFA3"}','Understated and premium.','celebration',6),
  ('f2000000-0000-0000-0000-000000000007','Sage & Bronze','{"#7C8A72","#9C7A4B","#E7E5DE"}','Calm and dignified.','memorial',7),
  ('f2000000-0000-0000-0000-000000000008','Slate & Stone','{"#3F4A54","#B9BEC4"}','Quiet and restrained.','memorial',8)
on conflict (id) do nothing;
