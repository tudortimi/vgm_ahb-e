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
package vgm_ahb;


sequence slave_sequence using item = transfer;

extend slave_sequence_driver {
  agent_id : agent_id;

  // This field is filled by the BFM before calling 'get_next_item()'.
  !bfm_transfer : transfer;
};

extend slave_sequence {
  agent_id : agent_id;
    keep agent_id == driver.agent_id;

  mid_do(s : any_sequence_item) is also {
    if s is a transfer (seq_item) {
      seq_item.direction = driver.bfm_transfer.direction;
      seq_item.address = driver.bfm_transfer.address;
    };
  };
};
'>
