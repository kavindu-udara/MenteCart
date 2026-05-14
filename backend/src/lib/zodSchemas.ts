import z from "zod";

export const signupSchema = z.object({
  email: z.string().trim().email("Invalid email address"),
  password: z
    .string()
    .min(6, "Password must be at least 6 characters long")
    .regex(
      /^(?=.*[A-Za-z])(?=.*\d)(?=.*[^A-Za-z\d])[^\s]{6,}$/,
      "Password must contain at least one letter, one number, and one symbol",
    ),
});

export const loginSchema = z.object({
  email: z.string().trim().email("Invalid email address"),
  password: z.string().min(6, "Password must be at least 6 characters long"),
});

export const addToCartSchema = z.object({
  serviceId: z.string().trim().length(24, "Invalid service ID"),
  selectedDate: z.string().refine((date) => {
    const parsedDate = new Date(date);
    return !isNaN(parsedDate.getTime());
  }, "Invalid date format"),
  timeSlotStart: z.string().trim().regex(/^([01]\d|2[0-3]):([0-5]\d)$/, "Invalid time format (HH:mm)"),
  timeSlotEnd: z.string().trim().regex(/^([01]\d|2[0-3]):([0-5]\d)$/, "Invalid time format (HH:mm)"),
});
