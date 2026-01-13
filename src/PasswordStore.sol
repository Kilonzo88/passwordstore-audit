// SPDX-License-Identifier: MIT
pragma solidity 0.8.18; // q is this the upto date compiler version

/*
 * @author not-so-secure-dev
 * @title PasswordStore
 * @notice This contract allows you to store a private password that others won't be able to see. 
 * You can update your password at any time.
 */
contract PasswordStore {
    error PasswordStore__NotOwner();

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    address private s_owner;
    //@audit- Medium: Storing passwords as plain text is insecure. Consider hashing the password before storing it.
    string private s_password;


    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event SetNetPassword();

    constructor() {
        s_owner = msg.sender;
    }

    /*
     * @notice This function allows only the owner to set a new password.
     * @param newPassword The new password to set.
     */

    //@audit- High: Any user can call this function to set the password, not just the owner.
    //missing access control
    function setPassword(string memory newPassword) external {
        s_password = newPassword;
        emit SetNetPassword();
    }

    /*
     * @notice This allows only the owner to retrieve the password.
     //@audit- There's no param for this function.
     * @param newPassword The new password to set.
     */
    function getPassword() external view returns (string memory) {
        if (msg.sender != s_owner) {
            revert PasswordStore__NotOwner();
        }
        return s_password;
    }
}
