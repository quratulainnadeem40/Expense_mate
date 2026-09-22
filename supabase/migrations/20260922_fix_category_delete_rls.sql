-- Allow category deletion to clear transaction references safely.
-- 1) Make category_id nullable if it is currently NOT NULL.
ALTER TABLE public.transactions
  ALTER COLUMN category_id DROP NOT NULL;

-- 2) If a foreign key exists, change it to ON DELETE SET NULL.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.table_constraints tc
    JOIN information_schema.key_column_usage kcu
      ON tc.constraint_name = kcu.constraint_name
    WHERE tc.table_schema = 'public'
      AND tc.table_name = 'transactions'
      AND tc.constraint_type = 'FOREIGN KEY'
      AND kcu.column_name = 'category_id'
  ) THEN
    ALTER TABLE public.transactions
      DROP CONSTRAINT IF EXISTS transactions_category_id_fkey;

    ALTER TABLE public.transactions
      ADD CONSTRAINT transactions_category_id_fkey
      FOREIGN KEY (category_id)
      REFERENCES public.categories(id)
      ON DELETE SET NULL;
  END IF;
END $$;

-- 3) Allow the user to update their own transaction rows so category_id can be cleared before category deletion.
CREATE POLICY "Users can update their own transactions"
ON public.transactions
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Optional: keep the existing select/delete policies if they already exist, but ensure the user can update.
