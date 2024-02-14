
//FINISHED 2/13 WORKSHOP

#[starknet::interface]
trait ICounter<T> {
    fn get_counter(self: @T) -> u32;
    fn increase_counter(ref self: T);
}

#[starknet::contract]
mod Counter {
    use kill_switch::IKillSwitchDispatcherTrait;
use super::ICounter;
    use kill_switch::IKillSwitchDispatcher;
    use starknet::ContractAddress;


    #[storage]
    struct Storage {
        counter: u32,
        kill_switch: IKillSwitchDispatcher,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        CounterIncreased: CounterIncreased,
    }
    
    #[derive(Drop, starknet::Event)]
    struct CounterIncreased {
        counter : u32,
    }



    #[constructor]
    fn constructor(ref self: ContractState, init_counter: u32, kill_switch_address : ContractAddress) {
        self.counter.write(init_counter);
        let dispatcher = IKillSwitchDispatcher{ contract_address: kill_switch_address};
        self.kill_switch.write(dispatcher);
    }


    #[abi(embed_v0)]
    impl CounterImpl of ICounter<ContractState> {

        fn get_counter(self: @ContractState) -> u32{
            self.counter.read()

        }

        fn increase_counter(ref self: ContractState){

            let dispatcher = self.kill_switch.read();

            if (dispatcher.is_active()) {
                let currrent_counter = self.counter.read();
                let new_counter = currrent_counter + 1;
                self.counter.write(currrent_counter + 1);
                self.emit(CounterIncreased{counter: new_counter});
            }

        }

    }
}
