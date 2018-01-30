function timeStr = formatTimeToMinSec(etime)
timeStr = sprintf('%d min, %d sec', floor(etime / 60), round(rem(etime, 60)));