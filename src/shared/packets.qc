// TODO: parse this via a #define based on some magic with the git tag?
float PROTO_VER = 1;

/**
 * key:
 * |b| byte
 * |bl| boolean (0/1), read as byte
 * |s| string
 * |v| vector
 * |f| float
 */

enum packetType {
    PKT_CHARACTER,
    PKT_INVENTORY = 1,
};

enum characterPacketType {
    /* S->C: The user has been logged out */
    PKT_C_LOGGED_OUT,

    /* S->C: The user has been logged in */
    PKT_C_LOGGED_IN,

    /* S->C: List Response: |b|count, (|b|id, |s|name, |s|class, |f|level)*count */
    PKT_C_LIST_RES,

    /* S->C: Create Response: |bl|success */
    PKT_C_CREATE_RES,

    /* S->C: Delete Response: |bl|success */
    PKT_C_DELETE_RES,

    /* C->S: List Characters: */
    PKT_C_LIST,

    /* C->S: Create Character: |s|name, |b|class */
    PKT_C_CREATE,

    /* C->S: Delete Character: |b|id */
    PKT_C_DELETE,

    /* C->S: Login char: |b|id */
    PKT_C_LOGIN,

    /* C->S: Logout char: */
    PKT_C_LOGOUT = 9,
};
