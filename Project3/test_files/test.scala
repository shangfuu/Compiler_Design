object test{

	val TrUe = true

	var ba = true
	var bb:boolean = false
	var ia = 5
	var ib:int
	var ca = 'c'
	// var sa = "is a string"
	var s3 : string
	var b1 : boolean [5]

	val False = false
	var fabtable: int[100]

	def correct(s:string, c: char, i: int, b:boolean, test:int) : string
	{
	
		while(b){
			i = i + 1
			i = i - 1
			if(i < 5){
				i = i / 1
				i = i * 1
			}
			if(s == "" || s == s && !s != s){
				c = 'b'
			}
			else{
				c = 'c'
			}

			for(i <- 5 to 10){
			b = true
			if(b >= true){
				b = false
			}
			if(i <= 9)
				i = 5
			}
		}
		return s
	}

	def fab(n: int) : int
	{
		if(fabtable[n] != -1)
		{
			return fabtable[n]
		}

		if(n < 0)
		{ 
			fabtable[n] = n 
		}
		else{
			fabtable[n] = fab(n-1) + fab(n-2)
		}
		return fabtable[n]
	}

	// procedure declaration
	def add(a:int, b:int) : int {
		return a+b 
	}

	def HelloWorld
	{
		val s = "Hey There"
		val i = -25
		val f = 3.14
		val b : boolean= false

		// Redefine S
		var s : string
		var i1 = 10
		var d : float
		var b2 : boolean = true

		var a : int [10]
		var f : float [10]
		var b : boolean [10]

		c = add(a, 10)
		s = "MAIN LA"
		println (c) 
	}
	
	def main()
	{
		var i = 0
		for(i <- 0 to 99)
			fabtable[i] = true

		sa = correct(sa, ca, ia, ba, ib)
		HelloWorld
		print(fab(50))
	}
}
