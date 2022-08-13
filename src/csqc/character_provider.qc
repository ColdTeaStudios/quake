
typedef struct {
    float id;
    string name;
    string class;
    float level;
} character_info_t;

typedef struct {
    float playing;
    float characterId;

    character_info_t char;
} character_state_t;

// Current state
character_state_t cState;

// Up to 4 character slots
character_info_t cInfo[4];

/* Responsible for handling QC<->CSQC character communication */
class CharacterProvider
{
    float characterCount;

    virtual void() CharacterProvider =
    {
        dprint("\b[CSQC]\b Character Provider constructor\n");
        cState.playing = FALSE;
        cState.characterId = -1;
    };

    virtual void() handlePacket =
    {
        characterPacketType e = ReadByte();

        switch (e) {
            case PKT_C_LIST_RES: return;
        }
    };

    virtual void(float characterId) login =
    {
        sendevent("ChrLogin", "f", characterId);
    };

    virtual void() logout =
    {
        sendevent("ChrLogout", "");
    };

    virtual void() getList =
    {
        sendevent("ChrList", "");
    };

    /* == Packet Handlers == */

    virtual void() handleListResponse =
    {
        characterCount = ReadByte();

        for (float i = 0; i < characterCount; i++) {
            cInfo[i].id = ReadByte();
            cInfo[i].name = ReadString();
            cInfo[i].class = ReadString();
            cInfo[i].level = ReadFloat();
        }
    };

    virtual void() handleLoggedOut =
    {
        cState.playing = FALSE;
        cState.characterId = -1;
    };

    virtual void() handleLoggedIn =
    {
        cState.playing = TRUE;
        cState.characterId = ReadByte();

        cState.char.id = cState.characterId;
        cState.char.name = ReadString();
        cState.char.class = ReadString();
        cState.char.level = ReadFloat();
    };

    virtual void() handleCreateResponse =
    {
        dprint("stub\n");
    };


    virtual void() handleDeleteResponse =
    {
        dprint("stub\n");
    };

    /* == Send messages to server == */
};

CharacterProvider provider;
