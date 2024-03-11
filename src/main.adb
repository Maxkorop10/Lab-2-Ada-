with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

procedure main is

   dim : constant Integer := 100;
   thread_num : constant Integer := 4;

   type arr_type is array (Positive range <>) of Integer;
   arr : arr_type(1..dim);

   procedure init_arr is
   begin
      for i in arr'range loop
         arr(i) := i;
      end loop;
      arr(10) := -15;
   end init_arr;

   function part_min(start_index, finish_index : in Integer) return Integer is
      min : Integer := Integer'Last;
   begin
      for i in start_index..finish_index loop
         if arr(i) < min then
            min := arr(i);
         end if;
      end loop;
      return min;
   end part_min;

   task type starter_thread is
      entry start(start_index, finish_index : in Integer);
   end starter_thread;

   protected part_manager is
      procedure set_part_min(min_val : in Integer);
      entry get_min(min_val : out Integer);
   private
      tasks_count : Integer := 0;
      min1 : Integer := Integer'Last;
   end part_manager;

   protected body part_manager is
      procedure set_part_min(min_val : in Integer) is
      begin
         if min_val < min1 then
            min1 := min_val;
         end if;
         tasks_count := tasks_count + 1;
      end set_part_min;

      entry get_min(min_val : out Integer) when tasks_count = thread_num is
      begin
         min_val := min1;
      end get_min;

   end part_manager;

   task body starter_thread is
      min_val : Integer := Integer'Last;
      start_index, finish_index : Integer;
   begin
      accept start(start_index, finish_index : in Integer) do
         starter_thread.start_index := start_index;
         starter_thread.finish_index := finish_index;
      end start;
      min_val := part_min(start_index  => start_index,
                          finish_index => finish_index);
      part_manager.set_part_min(min_val);
   end starter_thread;

   function parallel_min return Integer is
      min_val : Integer := Integer'Last;
      threads : array(1..thread_num) of starter_thread;
   begin
      for i in 1..thread_num loop
         threads(i).start((i - 1) * dim / thread_num + 1, i * dim / thread_num);
      end loop;
      part_manager.get_min(min_val);
      return min_val;
   end parallel_min;

   min_element : Integer;
   min_index : Integer;

begin
   init_arr;
   min_element := Integer'Last;
   min_index := 0;

   for i in arr'range loop
      if arr(i) < min_element then
         min_element := arr(i);
         min_index := i;
      end if;
   end loop;

   Put_Line("Minimal element: " & min_element'Image);
   Put_Line("Index of min. element: " & min_index'Image);

end main;
