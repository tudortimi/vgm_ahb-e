// Copyright 2016 Tudor Timisescu (verificationgentleman.com)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


<'
struct memory_location {
  address : uint(bits:32);
  value : byte;
};

extend slave_sequence_kind : [ MEMORY ];
extend MEMORY slave_sequence {
  !memory : list(key : address) of memory_location;
  !seq_item : transfer;


  body() @driver.clock is {
    while TRUE {
      do seq_item;
    };
  };

  mid_do(s : any_sequence_item) is also {
    if s is a transfer (seq_item) {
      if seq_item.direction == READ {
        update_read_data_from_memory(seq_item);
      };
    };
  };

  post_do(s : any_sequence_item) is also {
    if s is a transfer (seq_item) {
      if seq_item.direction == WRITE {
        update_memory_from_write_data(seq_item);
      };
    };
  };


  // TODO implement all sizes
  update_read_data_from_memory(seq_item : transfer) is {
    var word_address := driver.bfm_transfer.address;
    word_address[1:0] = 0b00;

    for i from 0 to 3 {
      if memory.key_exists(word_address + i) {
        seq_item.data[(i+1)*8-1:i*8] = memory.key(word_address + i).value;
      };
    };
  };


  // TODO implement for all sizes
  update_memory_from_write_data(seq_item : transfer) is {
    var word_address := seq_item.address;
    word_address[1:0] = 0b00;

    for i from 0 to 3 {
      var loc : memory_location = new with {
        .address = word_address + i;
        .value = seq_item.data[(i+1)*8-1:i*8];
      };
      if memory.key_exists(loc.address) {
        memory[memory.key_index(loc.address)] = loc;
      }
      else {
        memory.add(loc);
      };
    };
  };
};
'>
