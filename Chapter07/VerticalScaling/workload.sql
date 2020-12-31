-- Code is reviewed and is in working condition

SELECT 
	SUM(cast(a.object_id as bigint) + cast(b.object_id as bigint) + cast(c.object_id as bigint) + cast(d.object_id as bigint))
	as total
	FROM 
	sys.objects a, 
	sys.objects b,
	sys.objects c,
	sys.objects d,
	sys.objects e,
	sys.objects f,
	sys.objects g,
	sys.objects h
ORDER BY total
