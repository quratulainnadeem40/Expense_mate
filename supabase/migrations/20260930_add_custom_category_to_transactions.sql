ALTER TABLE public.transactions
  ADD COLUMN IF NOT EXISTS custom_category text;

NOTIFY pgrst, 'reload schema';
