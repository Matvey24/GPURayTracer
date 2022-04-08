#pragma once
#include <vector>
#include "../objects/Dot.h"

#define CH_TYPE_NOTYPE 0
#define CH_TYPE_STRAIGHT 1

struct DotState {
	Vector3 pos;
	Matrix rot;
	double dur;
	int ch_type;
};

class TimeLine
{
	std::vector<DotState> line;
	Dot& moving;

	double time_sum;
	int line_step;
public:
	TimeLine(Dot& dot);
	void addCurrState(double duration, int ch_type);
	void apply(double time);
};

