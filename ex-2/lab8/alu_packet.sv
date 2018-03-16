//Make your struct here
typedef struct{
   rand bit [0:7] a, b; 
   rand bit [0:2] op;
} data_t;

class alu_data;
        
	//Initialize your struct here
   rand data_t data;
   
        // Class methods(tasks) go here
   task get(ref bit [0:7] a, ref bit [0:7] b, ref bit [0:2] op);
      a = data.a;
      b = data.b;
      op = data.op;
   endtask

        // Constraints
   constraint c1{data.a inside{[0:127]};}
   constraint c2{data.b inside{[0:255]};}
   constraint c3{data.a inside{[0:6]};}

endclass: alu_data

