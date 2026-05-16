import z from "zod";

export const signupSchema = z.object({
  firstName: z.string().trim().min(1, "First name is required").max(50, "First name must be at most 50 characters long"),
  lastName: z.string().trim().min(1, "Last name is required").max(50, "Last name must be at most 50 characters long"),
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

export const bookingCheckoutSchema = z.object({
  paymentMethod: z.enum(["payhere", "cash", "pay_on_arrival"], "Invalid payment method"),
});

export const payhereCheckoutSchema = z.object({
  phone: z.string().trim().min(1, "Phone number is required").max(20, "Phone number must be at most 20 characters long"),
  address: z.string().trim().min(1, "Address is required").max(200, "Address must be at most 200 characters long"),
  city: z.string().trim().min(1, "City is required").max(100, "City must be at most 100 characters long"),
  country: z.string().trim().min(1, "Country is required").max(100, "Country must be at most 100 characters long"),
  order_id: z.string().trim().min(1, "Order ID is required").max(100, "Order ID must be at most 100 characters long"),
});
