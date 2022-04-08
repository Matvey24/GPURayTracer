#include "TimeLine.h"
TimeLine::TimeLine(Dot& dot):moving(dot), time_sum(0), line_step(0) {
	addCurrState(0, 0);
}
void TimeLine::addCurrState(double duration, int ch_type) {
	DotState state;
	state.pos = moving.pos;
	state.rot = moving.rot;
	state.dur = duration;
	state.ch_type = ch_type;
}
void TimeLine::apply(double time) {
	if (time < 0)
		time = 0;
	if (time < time_sum) {
		time_sum = 0;
		line_step = 0;
	}
	while (time_sum + line[line_step].dur > time) {
		if (line.size() - 1 == time_sum) {
			break;
		}
	}
}