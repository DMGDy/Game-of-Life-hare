use fmt;
use bufio;
use os;
use strconv;
use strings;
use math::random;
use time;

def SIZE: u32= 32;
def X: size = SIZE*2;
def Y: size = SIZE;

def CLEAR_SCREEN: str = "\x1b[2J";     
def CURSOR_HOME: str = "\x1b[H";       

fn next_generation(board: *[Y][X]int) void = {
	// track how many alive neighbors on each cell
	let alive_neighbors: [Y][X]int = [[0...]...];

	for(let y = 0i; y < Y:int; y += 1) {
		for(let x = 0i; x < X:int; x += 1) {
			for(let dy = -1i; dy < 2; dy += 1) {
				for(let dx = -1i; dx < 2; dx += 1) {
					if(dx == 0 && dy == 0) {
						continue;
					};
					if(((y+dy>=0)&&
						(y+dy)<Y:int)&&
						((x+dx>=0)&&
						(x+dx<X:int))) {
						alive_neighbors[y][x] += board[y+dy][x+dx];
					};
				};
			};
		};
	};


	for(let y = 0z; y < Y; y += 1) {
		// rules for cells to live
		for(let x = 0z; x < X; x += 1) {
			// overpopulation for alive cells if more than 3
			if(board[y][x] == 1 && alive_neighbors[y][x] > 3) {
				board[y][x] = 0i;
			} 
			// reproduce if dead cell has 3 alive neighbors
			else if(board[y][x] == 0 && alive_neighbors[y][x] == 3) {
				board[y][x] = 1i;
			}
			// cell dies if less than 2 neighbors
			else if(board[y][x] == 1 && alive_neighbors[y][x] < 2) {

				board[y][x] = 0i;
			}
			else {
				board[y][x] = board[y][x];
			};
		};
	};
};

fn show_board(board: [Y][X]int) void = {
	fmt::printf(CLEAR_SCREEN)!;
	fmt::printf(CURSOR_HOME)!;
	for(let x =0z;x<X+2;x+=1) {
		fmt::printf("-")!;
	};
	fmt::println()!;
	for(let y =0z;y<Y;y+=1) {
		fmt::printf("|")!;
		for(let x = 0z;x<X;x+=1) {
			if (board[y][x] == 0) { 
				fmt::printf(" ")!; 
			} else {
				fmt::printf("█")!;
			};
		};
		fmt::printf("|\n")!;
	};
	for(let x =0z;x<X+2;x+=1) {
		fmt::printf("-")!;
	};
	fmt::println()!;
};

fn modify(board: [Y][X]int) void = {
	board[0][0] = 1;
};

export fn main() void = {

	let board: [Y][X]int = [[0...]...];
	const seed = strconv::stou64(
		strings::fromutf8(
		bufio::read_line(os::stdin)! as []u8)!
	)!;

	fmt::printf("seed: {}\n",seed)!;
	let rand = random::init(seed);
	let starting_alive = SIZE/2; 
	// populate up to 10 other random clumps of 3 cells
	for(let i = 0z; i < starting_alive; i += 1) {
		let randx = random::u32n(&rand,SIZE);
		let randy = random::u32n(&rand,SIZE);
		board[randy][randx] = 1;

		// randomly determine the other 2 random life cells
		let up_or_down= random::u32n(&rand,2);
		let dy = 0;
		if(up_or_down == 1) {
			fmt::printf("down\n")!;
			dy = 1;
		} else {
			dy = -1;	
		};

		let dx = 0;
		let left_or_right= random::u32n(&rand,2);
		if(left_or_right == 1) {
			fmt::printf("right\n")!;
			dx = 1;
		} else {
			dx = -1;
		};
		
		// out of bounds check
		if(randx:int + dx > SIZE:int-1 || randx:int + dx < 0) {
			fmt::printf("true\n")!;
			dx *= -1;
		};
		board[randy][randx:int +dx] = 1;

		if(randy:int + dy > SIZE:int-1 || randy:int + dy < 0) {
			fmt::printf("true\n")!;
			dy *= -1;
		};
		board[randy:int + dy:int][randx] = 1;
	};



	show_board(board);

	for(true){
		next_generation(&board);
		show_board(board);
		time::sleep(250:time::duration * time::MILLISECOND);
	};

	
	//begin generations;
	
};
