"use client";

import { useState } from "react";
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Skeleton } from "@/components/ui/skeleton";
import { Copy, Download } from "lucide-react";
import { useLogs } from "@/hooks/use-logs";
import { toast } from "sonner";

function colorLogLine(line: string): string {
  if (line.includes(" - ERROR - ")) return "text-red-500";
  if (line.includes(" - WARNING - ")) return "text-yellow-500";
  return "text-muted-foreground";
}

export function LogViewer() {
  const [lineCount, setLineCount] = useState(100);
  const { data, isLoading } = useLogs(lineCount);

  const handleCopy = () => {
    if (data) {
      navigator.clipboard.writeText(data.lines.join(""));
      toast.success("Logs copied to clipboard");
    }
  };

  const handleDownload = () => {
    if (data) {
      const blob = new Blob([data.lines.join("")], { type: "text/plain" });
      const url = URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = "wbm_bot.log";
      a.click();
      URL.revokeObjectURL(url);
    }
  };

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between flex-wrap gap-2">
        <CardTitle>Logs</CardTitle>
        <div className="flex items-center gap-2">
          <Select
            value={String(lineCount)}
            onValueChange={(v) => setLineCount(Number(v))}
          >
            <SelectTrigger className="w-[100px]">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="50">50 lines</SelectItem>
              <SelectItem value="100">100 lines</SelectItem>
              <SelectItem value="200">200 lines</SelectItem>
            </SelectContent>
          </Select>
          <Button variant="outline" size="icon" onClick={handleCopy}>
            <Copy className="h-4 w-4" />
          </Button>
          <Button variant="outline" size="icon" onClick={handleDownload}>
            <Download className="h-4 w-4" />
          </Button>
        </div>
      </CardHeader>
      <CardContent>
        {isLoading ? (
          <Skeleton className="h-[400px] w-full" />
        ) : !data || data.lines.length === 0 ? (
          <div className="h-[400px] flex items-center justify-center text-muted-foreground">
            No logs available
          </div>
        ) : (
          <>
            <ScrollArea className="h-[400px] rounded-md border bg-muted/30 p-3">
              <div className="font-mono text-xs space-y-0.5">
                {data.lines.map((line, i) => (
                  <div key={i} className={colorLogLine(line)}>
                    {line.trimEnd()}
                  </div>
                ))}
              </div>
            </ScrollArea>
            <p className="text-xs text-muted-foreground mt-2">
              Showing {data.lines.length} of {data.total_lines} total lines
            </p>
          </>
        )}
      </CardContent>
    </Card>
  );
}
