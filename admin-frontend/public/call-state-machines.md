
## Outgoing

States:

    IDLE
    CALLING RINGING
    ONGOING
    UNANSWERED REJECTED ENDED
    
Events:

    SenderCallInit SenderHangUp SenderDisconnect
    ReceiverAck ReceiverReject ReceiverAccept ReceiverHangUp ReceiverDisconnect
    CallTimeout
    
Flowchart:

```mermaid
graph TD
    Idle -->|SenderCallInit| Calling
    Calling -->|ReceiverAck| Ringing
    Calling -->|Timeout| Unanswered
    Calling -->|ReceiverReject| Rejected
    Calling -->|SenderHangUp/Disconnect| Ended
    Ringing -->|ReceiverReject| Rejected
    Ringing -->|Timeout| Unanswered
    Ringing -->|ReceiverAccept| Ongoing
    Ringing -->|SenderHangUp/Disconnect| Ended
    Ongoing -->|ReceiverHangUp/Disconnect| Ended
    Ongoing -->|SenderHangUp/Disconnect| Ended
```


> [mermaid.live: outgoing](https://mermaid.live/edit#pako:eNqNks1uwjAQhF8l2nOgcTBx8KESgkrlUFWi9FLlYsVLcJvYkXH6B7x7TUgRlUDFF3tX34zH8m4gNxKBQ2FFvQoW00wHfs1kiUGvd7t9Qi1xIspyppXbBvuT0sUB6oqWm2OO6h3tOH_bBnPfPUstVIWm8T7PWuj1B1qUl63m-Iq5Zw_7ObINZ--FLp7rm6la50brVnLn-x3fZbnC-ZS8GPSc3TjPsfbsoy7M8dmn4DU5O_Ef4-sV_90Aof9gJYE722AIFdpK7EvY7L0ycCusMAPujxKXoildBpneeVkt9Isx1a_SmqZYAV-Kcu2rppbC4VQJPz3VsWvbMBPTaAc8TketCfANfAJPBv2YpoyRJGE0jSgL4ctDjPSTlMSMUkKjJB7uQvhub436LIoHLKUjQthwRAckBJTKGftwmNt2fHc_F6zrEA)


## Incoming

States:

    IDLE
    RINGING ONGOING
    ENDED REJECTED UNANSWERED

Events:

    ReceiverAck ReceiverReject ReceiverAccept
    SenderHangUp SenderDisconnect
    CallTimeout

Flowchart:

```mermaid
graph TD
   Idle -->|ReceiverAck| Ringing
   Idle -->|SenderHangUp/Disconnect| Ended
   Ringing -->|ReceiverReject| Rejected
   Ringing -->|CallTimeout| Unanswered
   Ringing -->|ReceiverAccept| Ongoing
   Ringing -->|SenderHangUp/Disconnect| Ended
   Ongoing -->|ReceiverHangUp/Disconnect| Ended
   Ongoing -->|SenderHangUp/Disconnect| Ended
```

> [mermaid.live: incoming](https://mermaid.live/edit#pako:eNqNkl1rwjAUhv9KOdfVtTEmJRcD0cF2MQZOb0ZvQnKs2dqkxHZf6n9frB_MMTZDIDknz_ueAzlrUE4jCIgKL-tlNJvkNgrrTpcY9XrXmykqNK_oR-plE02NLcL-gTyi1ehvpS3m9dXErJSzFlWziW5CXu_hg_LMcorPHbY_fyPHsixnpkLXBmxupV29of_LcqQU1oF9sIU7NfodvKTXg_jM-HLFfxUghsIbDaLxLcZQoa_kLoT1ziuHZokV5iDCVeNCtmWTQ263QVZL--RcdVR61xZLEAtZrkLU1lo2ODEy_GN1yvqumbFrbQOCprwzAbGGdxBs0Cc04zxljNMsoeHxAwThaZ9lKeGUpjRhZLiN4bOrmvR5QgY8o0POCEsoJTGgNo3z9_sR6iZp-wVIHMJ1)
