(*
	Copyright ©
	Author: Fabio Buglione
	Data Release: 2025/04/11
	Version: 1.0.0
*)
	
	
//----------------------------------------------------(* === CAMERA COMMAND SEQUENCE === *)----------------------------------------------------//

(* Rising edge of trigger signal *)
	IF (EDGEPOS(Trig)) THEN
		Trig_Memory 				:= TRUE;                   (* Store trigger event *)
		Error_No_Data_Found 		:= FALSE;                  (* Reset error flag *)
		Matrix_Found_And_Converted 	:= FALSE;                  (* Reset success flag *)
		MB_Command 					:= 1;                      (* Command 1: Stay in ready state *)
	END_IF

	(* If we triggered and the camera is ready *)
	IF Trig_Memory AND Status_FeedBack.Trigger_Ready THEN
		MB_Command 		:= 7;                              (* Command 7: Trigger read *)
	
		(* If result is available from the camera *)
	ELSIF Status_FeedBack.Result_Avaible THEN
		MB_Command 		:= 8;                              (* Command 8: Acknowledge reception *)
		ConvertData 	:= TRUE;                           (* Start data conversion *)

		(* After data is converted, reset cycle *)
	ELSIF DataConverted THEN
		MB_Command 		:= 1;                              (* Return to ready state *)
		Trig_Memory 	:= FALSE;                          (* Reset memory flag *)
		DataConverted	:= FALSE;                          (* Reset converted flag *)
		ConvertData		:= FALSE;                          (* Stop conversion process *)
	END_IF

	
//------------------------------------------------(* === PARSING STATUS WORD FROM CAMERA === *)------------------------------------------------//

	(* Each bit of MB_Status corresponds to a feedback signal from the camera *)
	Status_FeedBack.Trigger_Ready           := (MB_Status AND 16#0001) <> 0;   (* Camera ready for trigger *)
	Status_FeedBack.Trigger_Ack             := (MB_Status AND 16#0002) <> 0;   (* Trigger acknowledged *)
	Status_FeedBack.Acquiring               := (MB_Status AND 16#0004) <> 0;   (* Camera is acquiring image *)
	Status_FeedBack.Missed_Acq              := (MB_Status AND 16#0008) <> 0;   (* Acquisition missed *)
	Status_FeedBack.Deconding               := (MB_Status AND 16#0100) <> 0;   (* Decoding in progress *)
	Status_FeedBack.Decode_Complete_Toggle  := (MB_Status AND 16#0200) <> 0;   (* Toggle bit for decode complete *)
	Status_FeedBack.Result_Buffer_Overrun   := (MB_Status AND 16#0400) <> 0;   (* Buffer overrun error *)
	Status_FeedBack.Result_Avaible          := (MB_Status AND 16#0800) <> 0;   (* Result is available *)
	Status_FeedBack.General_Fault           := (MB_Status AND 16#8000) <> 0;   (* General fault in camera *)


//----------------------------------------------(* === CONVERTING RAW DATA TO ASCII STRING === *)----------------------------------------------//

	IF ConvertData THEN
	
		DataMatrix := '';                               (* Initialize output string *)

		FOR o := 0 TO 14 DO                             (* Loop through each 16-bit word *)
			highByte := SHR(MB_Data[o], 8);             (* Extract high byte by shifting right 8 bits *)
			lowByte  := MB_Data[o] AND 255;             (* Extract low byte with AND mask *)

			(* Store bytes into asciiString array at the correct index *)
			CASE o OF
				0:
					brsmemcpy(ADR(asciiString[0]), ADR(lowByte), SIZEOF(lowByte));
					brsmemcpy(ADR(asciiString[1]), ADR(highByte), SIZEOF(highByte));
				1:
					brsmemcpy(ADR(asciiString[2]), ADR(lowByte), SIZEOF(lowByte));
					brsmemcpy(ADR(asciiString[3]), ADR(highByte), SIZEOF(highByte));
				2:
					brsmemcpy(ADR(asciiString[4]), ADR(lowByte), SIZEOF(lowByte));
					brsmemcpy(ADR(asciiString[5]), ADR(highByte), SIZEOF(highByte));
				3:
					brsmemcpy(ADR(asciiString[6]), ADR(lowByte), SIZEOF(lowByte));
					brsmemcpy(ADR(asciiString[7]), ADR(highByte), SIZEOF(highByte));
				4:
					brsmemcpy(ADR(asciiString[8]), ADR(lowByte), SIZEOF(lowByte));
					brsmemcpy(ADR(asciiString[9]), ADR(highByte), SIZEOF(highByte));
				5:
					brsmemcpy(ADR(asciiString[10]), ADR(lowByte), SIZEOF(lowByte));
					brsmemcpy(ADR(asciiString[11]), ADR(highByte), SIZEOF(highByte));
				6:
					brsmemcpy(ADR(asciiString[12]), ADR(lowByte), SIZEOF(lowByte));
					brsmemcpy(ADR(asciiString[13]), ADR(highByte), SIZEOF(highByte));
				7:
					brsmemcpy(ADR(asciiString[14]), ADR(lowByte), SIZEOF(lowByte));
					brsmemcpy(ADR(asciiString[15]), ADR(highByte), SIZEOF(highByte));
				8:
					brsmemcpy(ADR(asciiString[16]), ADR(lowByte), SIZEOF(lowByte));
					brsmemcpy(ADR(asciiString[17]), ADR(highByte), SIZEOF(highByte));
				9:
					brsmemcpy(ADR(asciiString[18]), ADR(lowByte), SIZEOF(lowByte));
					brsmemcpy(ADR(asciiString[19]), ADR(highByte), SIZEOF(highByte));
				10:
					brsmemcpy(ADR(asciiString[20]), ADR(lowByte), SIZEOF(lowByte));
					brsmemcpy(ADR(asciiString[21]), ADR(highByte), SIZEOF(highByte));
				11:
					brsmemcpy(ADR(asciiString[22]), ADR(lowByte), SIZEOF(lowByte));
					brsmemcpy(ADR(asciiString[23]), ADR(highByte), SIZEOF(highByte));
				12:
					brsmemcpy(ADR(asciiString[24]), ADR(lowByte), SIZEOF(lowByte));
					brsmemcpy(ADR(asciiString[25]), ADR(highByte), SIZEOF(highByte));
				13:
					brsmemcpy(ADR(asciiString[26]), ADR(lowByte), SIZEOF(lowByte));
					brsmemcpy(ADR(asciiString[27]), ADR(highByte), SIZEOF(highByte));
				14:
					brsmemcpy(ADR(asciiString[28]), ADR(lowByte), SIZEOF(lowByte));
					brsmemcpy(ADR(asciiString[29]), ADR(highByte), SIZEOF(highByte));
			END_CASE

			FOR i := 0 TO 28 DO
				DataMatrix := CONCAT(DataMatrix, asciiString[i]);  (* Build the final ASCII string *)
			END_FOR;
		END_FOR

		DataConverted 	:= TRUE;                        (* Conversion complete *)
		Matrix_Found_And_Converted := TRUE;             (* Successfully read and parsed matrix *)

		IF DataMatrix = '' THEN                         (* Check if data is empty *)
			Error_No_Data_Found := TRUE;                (* Raise error flag *)
			Matrix_Found_And_Converted := FALSE;        (* Reset success flag *)
		END_IF

	END_IF