# B&R Structured Text – Modbus DataMatrix ASCII Decoder

This project contains a Structured Text implementation designed for use with B&R Automation Studio.  
It allows a PLC to interface with a Cognex DataMan camera via Modbus TCP/IP, trigger a read request, and decode the resulting DataMatrix string into readable ASCII format.

---

## 📦 Features

- 📸 **Camera Triggering Logic**  
  The PLC handles the full command cycle:
  - `Command 1`: Keep the camera in active/ready state
  - `Command 7`: Trigger a new acquisition
  - `Command 8`: Acknowledge the data received

- 🧠 **Status Word Decoding**  
  Parses the Modbus status word from the camera into individual boolean flags (Trigger Ready, Acquiring, Result Available, etc.)

- 🔤 **Data Conversion**  
  Converts 15 WORDs (30 bytes) of Modbus data into a valid ASCII string representing the decoded DataMatrix content.

- 🚫 **Error Handling**  
  Automatically checks if the decoded string is empty and raises a flag if no valid data is found.

---

## 🛠️ How It Works

1. On rising edge of `Trig`, the PLC prepares a trigger command.
2. When the camera is ready, it sends `Command 7` to initiate reading.
3. Once the result is available, it switches to `Command 8` and starts the ASCII conversion.
4. Each `WORD` received from the camera is split into `highByte` and `lowByte`, then merged into a 30-character ASCII string using `brsmemcpy`.
5. If no data is found, an error flag (`Error_No_Data_Found`) is raised.

---

## 🧾 Dependencies

- B&R Automation Studio (tested with v4.x or newer)
- `brsmemcpy` function block
- Cognex DataMan camera with Modbus TCP interface

---

## 📄 File Structure

- `DataMatrixDecoder.st` – Main logic to decode and process DataMatrix values.
- `README.md` – Project documentation (this file).
- *(Optional)* `LICENSE` – Licensing information (e.g. MIT).

---

## 👨‍💻 Author

Created by **[Your Name]** on *April 14, 2025*.  
Published on GitHub as proof of authorship and contribution to the B&R development ecosystem.

---

## 📘 License

You are free to use, adapt, and share this code under the terms of the MIT License.  
Just remember to give proper credit 🙌