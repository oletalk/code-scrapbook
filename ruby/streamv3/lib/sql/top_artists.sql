select item, sum(plays) as total_plays
from mp3s_stats 
where category = 'ARTIST' 
group by 1 
order by 2 desc 
limit 5