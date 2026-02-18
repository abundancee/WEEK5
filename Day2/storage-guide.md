# Data Storage in Solidity

## Where Structs, Mappings, and Arrays are Stored

So basically when you declare these data types at the contract level (as state variables), they get stored in storage. Storage is the permanent data that lives on the blockchain.

```solidity
contract Example {
    // these all go into storage
    mapping(address => uint) public balances;
    uint[] public numbers;
    
    struct User {
        string name;
        uint age;
    }
    User public user;
}
```

But when you use them inside functions, things work differently. Arrays and structs need you to say where they should be stored - either memory (temporary) or storage (permanent).

```solidity
function processData() public {
    uint[] memory tempArray = new uint[](5);  
    User memory newUser = User("Alice", 25);  
}
```

Here's what you need to know:
- **Mappings** - always in storage, you can't use them anywhere else
- **Arrays** - storage when they're state variables, but you have to specify memory/storage inside functions
- **Structs** - same as arrays

## How They Behave When You Call or Execute Them

### Mappings
Mappings are pretty straightforward. They're always stored permanently and any changes you make stick around. One thing to note - if you try to access a key that doesn't exist, it just returns 0 (or false, or whatever the default value is). You can't copy them or return them from functions either.

```solidity
mapping(address => uint) public balances;

function updateBalance(address user, uint amount) public {
    balances[user] = amount;  // this saves permanently
}
```

### Arrays

There's two types depending on where they are:

**Storage arrays** (the state variables):
- Any changes you make are permanent and saved to the blockchain
- Costs more gas because you're writing to blockchain storage
- You can use `.push()` and `.pop()` to add/remove items

```solidity
uint[] public storageArray;

function modify() public {
    storageArray.push(10);  // this is saved forever
}
```

**Memory arrays** (inside functions):
- Only exist while the function is running, then they're gone
- Way cheaper on gas
- You have to set the size when you create them, can't use `.push()` or `.pop()`

```solidity
function useMemory() public pure {
    uint[] memory tempArray = new uint[](5);
    tempArray[0] = 10;  // gone after this function finishes
}
```

### Structs

Works similar to arrays.

**Storage structs** save permanently and cost more gas:

```solidity
User public user;

function updateUser() public {
    user.name = "Bob";  // saved to blockchain
}
```

**Memory structs** are temporary and cheaper:

```solidity
function createTemp() public {
    User memory tempUser = User("Alice", 25);
    // this disappears when function ends
}
```

## Why You Don't Specify Memory or Storage with Mappings

This one confused me at first but it makes sense when you think about it.

**Mappings can only be in storage.** That's it. You can't create one in memory, so there's no point in specifying where it should go.

Here's why they have to be in storage:

1. **They can have unlimited keys** - imagine trying to copy something with potentially infinite entries into memory. It just doesn't work.

2. **They don't have a size** - unlike arrays where you can check `.length`, mappings don't track how many items they have. The EVM just calculates where to store each value using this formula:
   ```
   storage_slot = keccak256(key . mapping_slot)
   ```

3. **You can't copy them** - since you don't know all the keys that exist and there's no way to iterate through them, copying is impossible.

If you try to make a mapping in memory, your code won't even compile:

```solidity
// this DOESN'T work
function invalid() public {
    mapping(address => uint) memory balances;  // compile error!
}

// this is the right way
mapping(address => uint) public balances;  // works fine
```

Quick comparison:
- Mapping → only storage, no choice needed
- Array → storage or memory, you have to specify 
- Struct → storage or memory, you have to specify

## Summary

So to sum it up:
- **Storage** is permanent data on the blockchain (costs more gas)
- **Memory** is temporary data that exists only during function execution (cheaper)
- **Mappings** can only be in storage because they have infinite possible keys
- **Arrays and structs** can be either storage or memory, so you need to specify which one when using them in functions
