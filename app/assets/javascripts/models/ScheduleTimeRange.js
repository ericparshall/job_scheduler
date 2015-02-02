function ScheduleTimeRange(from_time, to_time, through_date) {
  this.from_time = from_time;
  this.to_time = to_time;
  
  if (through_date && through_date.isValid()) {
    this.through_date = through_date;
    if (this.from_time == null) {
      this.from_time = through_date;
    }
  } else if (through_date == null) {
      this.through_date = from_time;
  }
}

ScheduleTimeRange.prototype.getTotalHours = function() {
  if (this.from_time != null && this.to_time != null && this.from_time.isValid() && this.to_time.isValid()) {
    var total = this.to_time.diff(this.from_time, 'hours', true).toFixed(2);
    return total;
  } else {
    return 0;
  }
};

ScheduleTimeRange.prototype.getTotalHoursLabel = function() {
  var total = this.getTotalHours();
  var label = "";
  if (total >= 0) {
    label = total + " hours";
  }
  return label;
};