# SafeERC20

The SafeERC20 library exists primarily due to inconsistencies and potential lack of safety in the way ERC-20 tokens are implemented. Despite the ERC-20 standard's widespread adoption, it doesn't enforce strict adherence to its specifications, leading to variations in token contract behaviors, especially in the implementation of its functions like `transfer`, `transferFrom`, and `approve`. These variations can lead to unexpected behaviors, such as failing silently (not reverting or throwing an error) on unsuccessful operations, which can be particularly problematic in smart contracts that expect these operations to revert on failure.

## Return values

Not all ERC-20 tokens return a boolean value on success as per the standard. Some implementations might revert on failure, while others could return false or not return a value at all. `SafeERC20` uses call wrappers around these functions to ensure they behave consistently, reverting the transaction if the underlying token contract call doesn't succeed.

## When to Use SafeERC20

- Interacting with Multiple Tokens: When your contract is designed to interact with various ERC-20 tokens, whose implementations might differ or not fully adhere to the standard;

- Implementing Token Swaps and Transfers: In contracts that perform token swaps or facilitate token transfers, using `SafeERC20` can prevent unexpected failures and ensure that token operations revert the transaction if they don't execute as intended;

- Upgrading Existing Contracts: For legacy contracts or systems built before `SafeERC20` was widely adopted, integrating `SafeERC20` can enhance security and compatibility with a broader range of ERC-20 tokens.

In summary, SafeERC20 should be used in any smart contract development context where ERC-20 tokens are handled, to ensure compatibility, safety, and a consistent interface across different token implementations
