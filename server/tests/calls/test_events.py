from clearing_server.core.model.events import ReceiverAck, CallEvents


ack_event1 = ReceiverAck(
    client_token_id = "token1",
    sdp_answer="answer1"
)


def test_parse_ack_event():
    # GIVEN
    # a newly created call
    ack_json = ack_event1.model_dump_json()

    # WHEN
    # the json is parsed
    event = CallEvents.parse_json(ack_json)

    # THEN
    # parsing it gives back the same event
    assert event == ack_event1

