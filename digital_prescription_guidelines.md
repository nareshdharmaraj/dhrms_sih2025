Doctor Flow

After an appointment is confirmed,
→ instead of “Mark Complete” button → show “Attend the Patient” button.

Clicking “Attend the Patient” opens a new page/form to enter consultation details:

Patient Details to Collect

Disease name / problem

Disease type: Communicable / Not Communicable

If communicable → ask for expected recovery days (integer input, max 100 days)

Prescription Entry

Doctor can prescribe any number of medicines (not limited to one).

Options for medicine type: Tablet / Tonic / Injection

Tablet → name, power (optional), count per dose, time to take (morning/afternoon/evening/night), before/after food, number of days → then auto calculate total tablet count

Tonic → name, ml per dose, when to consume, number of days, before/after food

Injection → name, other related details

After each medicine is entered → ask “Continue Prescription” or “End Prescription”.

If continue → repeat asking Tablet/Tonic/Injection.

If end → generate prescription page.

_______________________________

📝 Digital Prescription Generation UI

The digital prescription page should look and feel like a real prescription paper. The layout must be simple, compact, and professional — with clear alignment.

📌 Header (Top Section)

Left Corner → App Name / Logo (small size, neat).

Right Corner → Hospital Name + Contact Information (address, phone/email).

Draw a thin horizontal line below the header to separate it from the body.

👨‍⚕️ Doctor & Patient Details (Compact Info Row)

Left side → Doctor Name, Doctor ID

Right side → Patient Name, UHID

Below (center aligned, small text) →

Date & Time

Appointment Number

Use small clear font, but ensure it is readable (like a hospital’s printed slip).

💊 Prescription Body

Organize medicines clearly under categories.

Add a section title in bold underline for each category (Tablets, Tonics, Injections).

Each medicine entry should be listed in a bullet/numbered format like a real doctor note.

1. Tablets Section

For each tablet prescribed, display:

• Tablet Name (Power/Strength if any)  
  → Count per dose: [x tablets]  
  → Timing: [Morning / Afternoon / Evening / Night]  
  → Instruction: [Before Food / After Food]  
  → Duration: [x days]  
  → Total Count: [auto-calculated tablets]  

2. Tonics Section

For each tonic prescribed:

• Tonic Name  
  → Dosage: [xx ml per dose]  
  → Timing: [Morning / Afternoon / Evening / Night]  
  → Instruction: [Before Food / After Food]  
  → Duration: [x days]  

3. Injections Section

For each injection prescribed:

• Injection Name  
  → Dosage / Frequency details (entered by doctor)  
  → Additional notes if any  

📅 Next Visit (Bottom Section)

Field: “Next Visit Date:” [Date entered by doctor]

If not given, display “Not Mandatory”

Align this towards bottom left.

✔️ Confirmation

Below the prescription, add a checkbox with text:
“I confirm this prescription is correct.”

Only after checking this → Enable “Save & Complete” button.

Once confirmed, prescription is stored neatly in the DB.

🎨 UI Look Guidelines

Use white background with a paper-like border (light grey outline).

Font should resemble real prescription slips:

Header: bold, small caps

Body: clean, readable (not too fancy)

Maintain compact spacing, not too much empty space.

Align everything neatly — no clutter.

🔍 Access

Doctor Side → After generation, doctor can view the saved prescription anytime under “Prescriptions”.

Patient Side → Under My Appointments → View Prescription (only visible after appointment status = Completed).
___________________________________